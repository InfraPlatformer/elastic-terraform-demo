# Staging Environment Main Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "elasticsearch-multi-cloud"
      ManagedBy   = "terraform"
    }
  }
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Data source for EKS cluster authentication
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Networking Module
module "networking" {
  source = "../../modules/networking"
  
  # VPC Configuration
  vpc_cidr = var.vpc_cidr_block
  availability_zones = var.availability_zones
  
  # Environment Configuration
  environment = var.environment
  
  # Security Configuration
  enable_vpc_endpoints = true
  
  # Tags
  tags = {
    Environment = var.environment
    Project     = "elasticsearch-multi-cloud"
    ManagedBy   = "terraform"
  }
}

# EKS Cluster Module
module "eks" {
  source = "../../modules/eks"
  
  # EKS Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.eks_cluster_version
  environment     = var.environment
  
  # Node Groups
  node_groups = var.eks_node_groups
  
  # VPC Configuration (from networking module)
  subnet_ids              = module.networking.private_subnets
  cluster_security_group_id = module.networking.eks_cluster_security_group_id
  nodes_security_group_id   = module.networking.eks_nodes_security_group_id
  
  # Cluster Access Configuration
  enable_public_access = true
  allowed_cidr_blocks  = ["0.0.0.0/0"]  # For staging, allow all IPs
  
  # Tags
  tags = {
    Environment = var.environment
    Project     = "elasticsearch-multi-cloud"
    ManagedBy   = "terraform"
  }
  
  depends_on = [module.networking]
}

# Elasticsearch will be deployed manually after EKS cluster is ready
# For now, we'll just deploy the EKS cluster and networking
