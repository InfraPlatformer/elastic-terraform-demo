# Staging Environment Variables

# Global Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "advanced-elastic"
}

# Environment Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "elasticsearch-cluster-staging"
}

variable "aws_cluster_name" {
  description = "Name of the AWS EKS cluster"
  type        = string
  default     = "advanced-elastic-staging-aws"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

# EKS Configuration
variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.28"
}

variable "eks_node_groups" {
  description = "EKS node groups configuration"
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
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      max_size       = 5
      min_size       = 2
      disk_size      = 100
      labels = {
        role = "elasticsearch"
      }
      taints = [{
        key    = "dedicated"
        value  = "elasticsearch"
        effect = "NO_SCHEDULE"
      }]
    }
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      disk_size      = 50
      labels = {
        role = "general"
      }
      taints = []
    }
  }
}

# VPC Configuration
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# Elasticsearch Configuration
variable "elasticsearch_replicas" {
  description = "Number of Elasticsearch replicas"
  type        = number
  default     = 3
}

variable "elasticsearch_resources" {
  description = "Elasticsearch resource requirements"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "4000m"
      memory = "8Gi"
    }
    requests = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

# Security Configuration
variable "enable_security" {
  description = "Enable security features"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Enable SSL/TLS"
  type        = bool
  default     = true
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable backup functionality"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 14
}

# Cost Optimization
variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

# Additional Required Variables
variable "aws_node_groups" {
  description = "AWS EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    elasticsearch = {
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 5
      desired_size   = 3
      disk_size      = 100
      labels = {
        role = "elasticsearch"
      }
      taints = []  # Remove taints to allow CoreDNS and other system pods to schedule
    }
  }
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public access to the cluster"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ebs_csi_driver" {
  description = "Enable AWS EBS CSI driver"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver"
  type        = string
  default     = "v1.20.0"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "advanced-elastic"
    Environment = "staging"
    ManagedBy   = "terraform"
    Purpose     = "elasticsearch-staging"
    Primary     = "elasticsearch"
  }
}

