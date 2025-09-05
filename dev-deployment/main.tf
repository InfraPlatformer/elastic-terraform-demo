# =============================================================================
# DEVELOPMENT ELASTICSEARCH INFRASTRUCTURE (AWS ONLY)
# =============================================================================

# AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      Purpose     = "elastic-stack"
    }
  }
}

# Kubernetes Provider for AWS EKS
provider "kubernetes" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Data source for EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_eks.cluster_name
}

# AWS EKS Module
module "aws_eks" {
  source = "../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  aws_region      = var.aws_region
  aws_vpc_cidr    = var.aws_vpc_cidr

  node_groups = var.aws_node_groups

  enable_ebs_csi_driver = var.enable_ebs_csi_driver
  ebs_csi_driver_version = var.ebs_csi_driver_version

  enable_public_access = var.enable_public_access
  allowed_cidr_blocks  = var.allowed_cidr_blocks

  enable_vpc_endpoints = var.enable_vpc_endpoints

  common_tags = var.common_tags
}
