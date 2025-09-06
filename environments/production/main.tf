# =============================================================================
# PRODUCTION ENVIRONMENT MAIN CONFIGURATION
# =============================================================================
# Enterprise-grade production configuration for AWS EKS
# Optimized for high availability, security, and performance
# =============================================================================

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
  
  # Production state should be stored in S3 with encryption and locking
  backend "s3" {
    # Configure via environment variables or terraform init -backend-config
    # bucket = "your-terraform-state-bucket"
    # key    = "production/terraform.tfstate"
    # region = "us-west-2"
    # encrypt = true
    # dynamodb_table = "terraform-state-lock"
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      CostCenter  = "production"
      Owner       = var.owner
    }
  }
}

# Configure Kubernetes Provider - AWS EKS
provider "kubernetes" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.aws_eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.aws_eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# VPC MODULE
# =============================================================================

module "vpc" {
  source = "../../modules/networking"

  environment = var.environment
  vpc_cidr = var.aws_vpc_cidr
  
  # Multi-AZ configuration for high availability
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # VPC endpoints for production
  enable_vpc_endpoints = var.enable_vpc_endpoints
  
  tags = var.common_tags
}

# =============================================================================
# EKS CLUSTER MODULE
# =============================================================================

module "aws_eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  environment = var.environment

  # VPC Configuration
  subnet_ids = module.vpc.private_subnets
  cluster_security_group_id = module.vpc.eks_cluster_security_group_id
  nodes_security_group_id = module.vpc.eks_nodes_security_group_id

  # Production node groups
  node_groups = var.aws_node_groups

  # Production security configuration
  enable_public_access = var.enable_public_access
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  # EBS CSI Driver
  enable_ebs_csi_driver = var.enable_ebs_csi_driver
  ebs_csi_driver_version = var.ebs_csi_driver_version

  tags = var.common_tags
}

# =============================================================================
# KMS ENCRYPTION
# =============================================================================
# Temporarily disabled due to KMS permissions issues
# KMS keys will be created manually or with proper permissions later

# # KMS key for EKS cluster encryption
# resource "aws_kms_key" "eks" {
#   description             = "EKS cluster encryption key for ${var.cluster_name}"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true
# }

# # KMS key for EBS volumes
# resource "aws_kms_key" "ebs" {
#   description             = "EBS volume encryption key for ${var.cluster_name}"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true
# }

# =============================================================================
# ELASTICSEARCH MODULE
# =============================================================================
module "elasticsearch" {
  source = "../../modules/elasticsearch"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  environment = var.environment
  
  # VPC and networking
  subnet_ids = module.vpc.private_subnets
  cluster_security_group_id = module.vpc.eks_cluster_security_group_id
  nodes_security_group_id = module.vpc.eks_nodes_security_group_id
  
  # Node groups
  node_groups = var.aws_node_groups
  
  # Elasticsearch configuration
  elasticsearch_data_nodes = var.elasticsearch_data_nodes
  elasticsearch_heap_size = var.elasticsearch_heap_size
  
  # Security
  enable_security = var.enable_security
  enable_encryption_at_rest = var.enable_security
  enable_encryption_in_transit = var.enable_ssl
  
  # Access
  enable_public_access = var.enable_public_access
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  # SSH access
  ssh_key_name = var.ssh_key_name
  
  # Tags
  tags = var.common_tags

  depends_on = [module.aws_eks]
}

# =============================================================================
# KIBANA MODULE
# =============================================================================
module "kibana" {
  source = "../../modules/kibana"

  cluster_name = var.cluster_name
  environment = var.environment
  kibana_version = var.kibana_version
  elasticsearch_hosts = ["http://elasticsearch.${var.environment}.svc.cluster.local:9200"]
  kibana_replicas = var.kibana_replicas
  enable_security = var.enable_security
  enable_ingress = var.enable_ingress
  tags = var.common_tags

  depends_on = [module.elasticsearch]
}

# =============================================================================
# MONITORING STACK MODULE
# =============================================================================
# Temporarily disabled due to Kubernetes API timeout issues
# Will be enabled after basic applications are deployed
# module "monitoring" {
#   source = "../../modules/monitoring"

#   environment = var.environment
#   grafana_admin_password = var.grafana_admin_password
#   monitoring_retention_days = var.monitoring_retention_days
#   enable_alerting = var.enable_monitoring
#   enable_logging = var.enable_logging
#   enable_security_monitoring = var.enable_security
#   storage_class = "gp3"
#   monitoring_namespace = "monitoring"
#   enable_fluentd = var.enable_logging
#   eks_cluster = module.aws_eks
#   enable_prometheus_operator = var.enable_monitoring
# }

# =============================================================================
# BACKUP CONFIGURATION
# =============================================================================

# S3 bucket for Elasticsearch backups
resource "aws_s3_bucket" "elasticsearch_backups" {
  count = var.enable_backup ? 1 : 0
  
  bucket = "${var.project_name}-${var.environment}-elasticsearch-backups-${random_string.bucket_suffix[0].result}"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-elasticsearch-backups"
    Purpose = "elasticsearch-backups"
  })
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  count = var.enable_backup ? 1 : 0
  
  length  = 8
  special = false
  upper   = false
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "elasticsearch_backups" {
  count = var.enable_backup ? 1 : 0
  
  bucket = aws_s3_bucket.elasticsearch_backups[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "elasticsearch_backups" {
  count = var.enable_backup ? 1 : 0
  
  bucket = aws_s3_bucket.elasticsearch_backups[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Use AWS managed encryption instead of KMS
    }
  }
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "elasticsearch_backups" {
  count = var.enable_backup ? 1 : 0
  
  bucket = aws_s3_bucket.elasticsearch_backups[0].id

  rule {
    id     = "backup_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.backup_retention_days + 365  # Ensure expiration is after all transitions
    }
  }
}

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================

# IAM role for Elasticsearch backup service
resource "aws_iam_role" "elasticsearch_backup" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.cluster_name}-elasticsearch-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM policy for S3 backup access
resource "aws_iam_policy" "elasticsearch_backup" {
  count = var.enable_backup ? 1 : 0
  
  name        = "${var.cluster_name}-elasticsearch-backup-policy"
  description = "Policy for Elasticsearch backup to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.elasticsearch_backups[0].arn,
          "${aws_s3_bucket.elasticsearch_backups[0].arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "elasticsearch_backup" {
  count = var.enable_backup ? 1 : 0
  
  role       = aws_iam_role.elasticsearch_backup[0].name
  policy_arn = aws_iam_policy.elasticsearch_backup[0].arn
}

# =============================================================================
# CLOUDWATCH LOG GROUPS
# =============================================================================

# CloudWatch log group for EKS cluster
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = var.common_tags
}

# CloudWatch log group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = 30

  tags = var.common_tags
}
