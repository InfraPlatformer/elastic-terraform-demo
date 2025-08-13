# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "demo"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# EKS Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "elastic-demo-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    desired_size  = number
  }))
  default = {
    elasticsearch = {
      instance_type = "t3.medium"
      min_size      = 2
      max_size      = 5
      desired_size  = 3
    }
    kibana = {
      instance_type = "t3.small"
      min_size      = 1
      max_size      = 3
      desired_size  = 2
    }
  }
}

# Elasticsearch Configuration
variable "elasticsearch_version" {
  description = "Elasticsearch version to deploy"
  type        = string
  default     = "8.11.0"
}

variable "elasticsearch_replicas" {
  description = "Number of Elasticsearch replicas"
  type        = number
  default     = 2
}

variable "elasticsearch_storage_size" {
  description = "Storage size for Elasticsearch PVC"
  type        = string
  default     = "100Gi"
}

variable "elasticsearch_memory_limit" {
  description = "Memory limit for Elasticsearch pods"
  type        = string
  default     = "2Gi"
}

variable "elasticsearch_cpu_limit" {
  description = "CPU limit for Elasticsearch pods"
  type        = string
  default     = "1000m"
}

# Kibana Configuration
variable "kibana_version" {
  description = "Kibana version to deploy"
  type        = string
  default     = "8.11.0"
}

variable "kibana_replicas" {
  description = "Number of Kibana replicas"
  type        = number
  default     = 2
}

variable "kibana_storage_size" {
  description = "Storage size for Kibana PVC"
  type        = string
  default     = "10Gi"
}

variable "kibana_memory_limit" {
  description = "Memory limit for Kibana pods"
  type        = string
  default     = "1Gi"
}

variable "kibana_cpu_limit" {
  description = "CPU limit for Kibana pods"
  type        = string
  default     = "500m"
}

# Security Configuration
variable "enable_tls" {
  description = "Enable TLS encryption for Elasticsearch"
  type        = bool
  default     = false
}

variable "elastic_password" {
  description = "Password for elastic user"
  type        = string
  default     = "changeme123!"
  sensitive   = true
}

variable "kibana_password" {
  description = "Password for kibana user"
  type        = string
  default     = "changeme123!"
  sensitive   = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable centralized logging"
  type        = bool
  default     = true
}

# Ingress Configuration
variable "enable_ingress" {
  description = "Enable ingress controller for external access"
  type        = bool
  default     = false
}

# Autoscaling Configuration
variable "enable_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "elastic-terraform-demo"
    ManagedBy   = "terraform"
    Owner       = "iac-demo"
    Purpose     = "presentation"
  }
} 