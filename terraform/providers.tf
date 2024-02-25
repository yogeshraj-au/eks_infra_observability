terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

provider "local" {

}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  host                   = data.aws_eks_cluster.log-metric.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.log-metric.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.log-metric.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
    command     = "aws"
  }
}