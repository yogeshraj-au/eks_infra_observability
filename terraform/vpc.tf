locals {
  name = "kubegalaxy"
}

#Define VPC module to create vpc, public and private subnets, route tables, nat gateways.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs            = var.azs            #provie the list of az's
  public_subnets = var.public_subnets #provide the list of cidr blocks

  public_subnet_tags_per_az = {
    us-east-1a = {
      Name = "${local.name}-public-1",
      "kubernetes.io/role/elb" = "1"
    },
    us-east-1b = {
      Name = "${local.name}-public-2",
      "kubernetes.io/role/elb" = "1"
    },
    us-east-1c = {
      Name = "${local.name}-public-3",
      "kubernetes.io/role/elb" = "1"
    }
  }

  public_route_table_tags = {
    Name = "${local.name}-public-routes"
  }

  private_subnets = var.private_subnets #provide the list of cidr blocks

  private_subnet_tags_per_az = {
    us-east-1a = {
      Name = "${local.name}-private-1",
      "kubernetes.io/role/internal-elb" = "1",
    },
    us-east-1b = {
      Name = "${local.name}-private-2",
      "kubernetes.io/role/internal-elb" = "1",
    },
    us-east-1c = {
      Name = "${local.name}-private-3",
      "kubernetes.io/role/internal-elb" = "1"
    }
  }

  private_route_table_tags = {
    Name = "${local.name}-private-routes"
  }

  #Create one NAT Gateway per AZ and associate it to elastic IP
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  reuse_nat_ips          = true
  external_nat_ip_ids    = aws_eip.nat.*.id

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${local.name}"
    Environment = "${var.environment}"
  }
}

#Create the Elastic IP's for nat gateway
resource "aws_eip" "nat" {
  count  = var.eip_count
  domain = "vpc"
}