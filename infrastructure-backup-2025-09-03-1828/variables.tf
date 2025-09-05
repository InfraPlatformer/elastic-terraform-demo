# =============================================================================
# VARIABLES FOR ADVANCED ELASTIC TERRAFORM SETUP
# =============================================================================

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "advanced-elastic"
}

variable "environment" {
  description = "Environment (production, staging, development)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development"
  }
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "kubernetes_version" {
  description = "Kubernetes version for clusters"
  type        = string
  default     = "1.29"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "advanced-elastic-staging-aws"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

# =============================================================================
# AWS CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_node_groups" {
  description = "AWS EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))

  default = {
    elasticsearch = {
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 5
      desired_size   = 3
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
    monitoring = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 50
      labels = {
        role = "monitoring"
      }
      taints = []
    }
  }
}

# =============================================================================
# AZURE CONFIGURATION
# =============================================================================

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure client ID (service principal)"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure client secret (service principal)"
  type        = string
  sensitive   = true
}

variable "azure_resource_group" {
  description = "Azure resource group name"
  type        = string
  default     = "multi-cloud-elastic-rg"
}

variable "azure_location" {
  description = "Azure region for infrastructure"
  type        = string
  default     = "West US 2"
}

variable "azure_node_pools" {
  description = "Azure AKS additional node pools"
  type = map(object({
    vm_size             = string
    os_disk_size_gb     = number
    count               = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_labels         = map(string)
    node_taints         = list(string)
  }))

  default = {
    elasticsearch = {
      vm_size             = "Standard_D2s_v3"
      os_disk_size_gb     = 100
      count               = 2
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      node_labels = {
        role = "elasticsearch"
      }
      node_taints = []
    }
    monitoring = {
      vm_size             = "Standard_D2s_v3"
      os_disk_size_gb     = 50
      count               = 1
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 3
      node_labels = {
        role = "monitoring"
      }
      node_taints = []
    }
  }
}

# =============================================================================
# STORAGE CONFIGURATION
# =============================================================================

variable "enable_ebs_csi_driver" {
  description = "Enable AWS EBS CSI Driver for dynamic volume provisioning"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_version" {
  description = "Version of AWS EBS CSI Driver to deploy"
  type        = string
  default     = "v2.20.0"
}

# =============================================================================
# PERFORMANCE & SCALING
# =============================================================================

variable "elasticsearch_heap_size" {
  description = "Elasticsearch JVM heap size"
  type        = string
  default     = "2g"
}

variable "elasticsearch_data_nodes" {
  description = "Number of Elasticsearch data nodes"
  type        = number
  default     = 3
}

variable "elasticsearch_master_nodes" {
  description = "Number of Elasticsearch master nodes"
  type        = number
  default     = 3
}

variable "elasticsearch_ingest_nodes" {
  description = "Number of Elasticsearch ingest nodes"
  type        = number
  default     = 2
}

variable "kibana_replicas" {
  description = "Number of Kibana replicas"
  type        = number
  default     = 2
}

# =============================================================================
# NETWORKING & ACCESS
# =============================================================================

variable "enable_public_access" {
  description = "Enable public access to EKS control plane (required for private nodes)"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Changed for EKS public access - use specific IPs in production
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

# =============================================================================
# TAGS & LABELS
# =============================================================================

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "advanced-elastic"
    Environment = "development"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
    Purpose     = "elastic-stack"
    CostCenter  = "engineering"
  }
}

# =============================================================================
# MONITORING & GRAFANA
# =============================================================================

variable "grafana_admin_password" {
  description = "Admin password for Grafana dashboard"
  type        = string
  default     = "admin123"
  sensitive   = true
}

# =============================================================================
# SSH ACCESS CONFIGURATION
# =============================================================================

variable "ssh_key_name" {
  description = "SSH key name for EC2 instance access"
  type        = string
  default     = ""
}

# =============================================================================
# MULTI-CLOUD DEPLOYMENT FLAGS
# =============================================================================

variable "enable_aws_deployment" {
  description = "Enable Elasticsearch deployment on AWS EKS"
  type        = bool
  default     = true
}

variable "enable_azure_deployment" {
  description = "Enable Elasticsearch deployment on Azure AKS"
  type        = bool
  default     = true
}
