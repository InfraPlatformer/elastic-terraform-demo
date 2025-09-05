# =============================================================================
# DEVELOPMENT VARIABLES
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "elasticsearch-dev"
}

variable "environment" {
  description = "Environment (development)"
  type        = string
  default     = "development"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "elasticsearch-dev-aws"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_node_groups" {
  description = "AWS EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    max_size       = number
    min_size       = number
    disk_size      = number
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {
    elasticsearch = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      disk_size      = 50
    }
  }
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_version" {
  description = "EBS CSI driver version"
  type        = string
  default     = "v1.28.0-eksbuild.1"
}

variable "enable_public_access" {
  description = "Enable public access to EKS cluster"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "elasticsearch-dev"
    Environment = "development"
    ManagedBy   = "terraform"
  }
}
