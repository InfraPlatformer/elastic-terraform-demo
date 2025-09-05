# =============================================================================
# DEVELOPMENT ENVIRONMENT VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region for the development environment"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "elasticsearch-dev"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}
