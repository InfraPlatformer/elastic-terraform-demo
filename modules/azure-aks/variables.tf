# Azure AKS Module Variables

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "elastic-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_vm_size" {
  description = "VM size for the AKS nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB for the nodes"
  type        = number
  default     = 100
}

variable "subnet_id" {
  description = "ID of the subnet for the AKS nodes"
  type        = string
}

variable "gateway_subnet_id" {
  description = "ID of the subnet for the Application Gateway"
  type        = string
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for the DNS service"
  type        = string
  default     = "10.1.0.10"
}

variable "node_taints" {
  description = "Taints for the nodes"
  type        = list(string)
  default     = []
}

variable "node_labels" {
  description = "Labels for the nodes"
  type        = map(string)
  default = {
    "role" = "elasticsearch"
  }
}

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups with admin access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "elastic-stack"
    ManagedBy   = "terraform"
  }
}