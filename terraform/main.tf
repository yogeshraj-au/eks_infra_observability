locals {
  cluster_name = "log-metric-${var.region}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    kube_ondemand = {
      min_size     = 1
      max_size     = 15
      desired_size = 1

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "kube_ondemand"
      }

      kube_spot = {
        min_size     = 1
        max_size     = 15
        desired_size = 1

        instance_types = ["m5n.large"]
        capacity_type  = "SPOT"

        labels = {
          role = "kube_spot"
        }

        tags = {
          Environment = "${var.environment}"
        }
      }
    }
  }


  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${module.iam_assumable_role.iam_role_arn}"
      username = "${module.iam_assumable_role.iam_role_name}"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "log-metric" {
  depends_on = [module.eks.cluster_name]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "log-metric" {
  depends_on = [module.eks.cluster_name]
  name = module.eks.cluster_name
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.log-metric.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


resource "aws_eks_addon" "ebs-csi-driver" {
  cluster_name = module.eks.cluster_name
  addon_name = "aws-ebs-csi-driver"
  addon_version = "v1.27.0-eksbuild.1"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}