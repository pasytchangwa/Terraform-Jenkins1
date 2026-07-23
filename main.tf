#####################################
# VPC MODULE
#####################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = ["us-east-1a", "us-east-1b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true

  tags = {
    Terraform  = "true"
    Environment = "Dev"
    Project     = "EKS-Lab"
  }

}

#####################################
# EKS MODULE
#####################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  ###################################
  # Networking
  ###################################

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  ###################################
  # Authentication
  ###################################

  enable_cluster_creator_admin_permissions = true

  ###################################
  # IRSA
  ###################################

  enable_irsa = true

  ###################################
  # Managed Node Group
  ###################################

  eks_managed_node_groups = {

    default = {

      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.micro"]

      ami_type = "AL2023_x86_64_STANDARD"

      capacity_type = "ON_DEMAND"

      disk_size = 20
    }
  }

  ###################################
  # Tags
  ###################################

  tags = {
    Environment = "Dev"
    Terraform   = "true"
    Project     = "EKS-Lab"
  }
}
