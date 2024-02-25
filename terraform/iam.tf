module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  name        = "eks-access-policy"
  path        = "/"
  description = "eks-access-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.33.0"

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]

  create_role = true

  role_name         = "eks-admin"
  role_requires_mfa = false

  custom_role_policy_arns = [module.iam_policy.arn]

  number_of_custom_role_policy_arns = 1
}

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.33.0"

  name                    = "steve"
  force_destroy           = true
  create_iam_access_key   = false
  password_reset_required = false
}

module "eks_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  name        = "eks-admin-policy"
  path        = "/"
  description = "eks-admin-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = module.iam_assumable_role.iam_role_arn
      }
    ]
  })
}


module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.33.0"

  name = "eks-admin"

  group_users = [
    module.iam_user.iam_user_name
  ]

  create_group                      = true
  attach_iam_self_management_policy = false

  custom_group_policy_arns = [module.eks_access_policy.arn]
}

module "iam_eks_role_autoscaler" {
  source                           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                          = "5.33.0"
  role_name                        = "eks-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = ["${module.eks.cluster_name}"]

  oidc_providers = {
    log-metric = {
      provider_arn               = "${module.eks.oidc_provider_arn}"
      namespace_service_accounts = ["kube-system:eks-cluster-autoscaler"]
    }
  }
}

module "iam_eks_role_lb" {
  source                           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                          = "5.33.0"
  role_name                        = "eks-lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    log-metric = {
      provider_arn               = "${module.eks.oidc_provider_arn}"
      namespace_service_accounts = ["kube-system:eks-lb"]
    }
  }
}

module "iam_eks_role_dns" {
  source                           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                          = "5.33.0"
  role_name                        = "external-dns"
  attach_external_dns_policy = true

  oidc_providers = {
    log-metric = {
      provider_arn               = "${module.eks.oidc_provider_arn}"
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}

module "iam_eks_role_cert" {
  source                           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                          = "5.33.0"
  role_name                        = "cert-manager"
  attach_cert_manager_policy = true

  oidc_providers = {
    log-metric = {
      provider_arn               = "${module.eks.oidc_provider_arn}"
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}


