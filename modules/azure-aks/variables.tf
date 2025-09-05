# =============================================================================
# AZURE AKS MODULE VARIABLES
# =============================================================================

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29.0"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
  default     = "West US 2"
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "service_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
  default     = "10.96.0.0/12"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
  default     = "10.96.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

# Default Node Pool Configuration
variable "default_node_pool" {
  description = "Configuration for the default node pool"
  type = object({
    vm_size             = string
    os_disk_size_gb     = number
    count               = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_labels         = map(string)
    node_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })

  default = {
    vm_size             = "Standard_D2s_v3"
    os_disk_size_gb     = 100
    count               = 2
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    node_labels = {
      role = "default"
    }
    node_taints = []
  }
}

# Additional Node Pools
variable "additional_node_pools" {
  description = "Configuration for additional node pools"
  type = map(object({
    vm_size             = string
    os_disk_size_gb     = number
    count               = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_labels         = map(string)
    node_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))

  default = {
    elasticsearch = {
      vm_size             = "Standard_D4s_v3"
      os_disk_size_gb     = 200
      count               = 3
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 6
      node_labels = {
        role = "elasticsearch"
      }
      node_taints = [{
        key    = "dedicated"
        value  = "elasticsearch"
        effect = "NoSchedule"
      }]
    }

    kibana = {
      vm_size             = "Standard_D2s_v3"
      os_disk_size_gb     = 100
      count               = 2
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 4
      node_labels = {
        role = "kibana"
      }
      node_taints = [{
        key    = "dedicated"
        value  = "kibana"
        effect = "NoSchedule"
      }]
    }

    monitoring = {
      vm_size             = "Standard_D2s_v3"
      os_disk_size_gb     = 100
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

# Container Registry
variable "enable_container_registry" {
  description = "Enable Azure Container Registry"
  type        = bool
  default     = true
}
