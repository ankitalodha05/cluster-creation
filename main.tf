# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks_cluster_vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/private_elb"       = 1
  }
}

# EKS Module
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "my-eks-cluster"
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = var.instance_types
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# Data Source: EKS Cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

# Data Source: EKS Cluster Authentication
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_certificate" {
  value = data.aws_eks_cluster.cluster.certificate_authority[0].data
}
Explanation of Changes
Fixed data Blocks:

Updated data "aws_eks_cluster" and data "aws_eks_cluster_auth" to use module.eks.cluster_name instead of module.eks.cluster_id.
Validated Cluster Version:

Changed cluster_version to 1.27 (a valid EKS version).
Added Outputs:

Outputs for VPC ID, cluster name, endpoint, and certificate authority were added to make cluster details easily accessible.
Provider and Terraform Requirements:

Updated the AWS provider version to >= 5.0 and Terraform version to >= 1.0.
Dynamic Availability Zones:

Used data "aws_availability_zones" to dynamically fetch availability zones.
Variables (Add these in variables.tf)
hcl
Copy code
variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "instance_types" {
  default = ["t3.medium"]
}
