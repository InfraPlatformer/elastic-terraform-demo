# Azure Staging Environment Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "elastic-stack"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US 2"
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

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR block for the AKS subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "gateway_subnet_cidr" {
  description = "CIDR block for the Application Gateway subnet"
  type        = list(string)
  default     = ["10.1.2.0/24"]
}

variable "enable_firewall" {
  description = "Enable Azure Firewall"
  type        = bool
  default     = false
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

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups with admin access"
  type        = list(string)
  default     = []
}

# Elasticsearch Configuration
variable "elasticsearch_version" {
  description = "Elasticsearch version"
  type        = string
  default     = "8.11.0"
}

variable "elasticsearch_replicas" {
  description = "Number of Elasticsearch replicas"
  type        = number
  default     = 1
}

variable "elasticsearch_heap_size" {
  description = "Elasticsearch heap size"
  type        = string
  default     = "2g"
}

variable "elasticsearch_memory_requests" {
  description = "Elasticsearch memory requests"
  type        = string
  default     = "4Gi"
}

variable "elasticsearch_cpu_requests" {
  description = "Elasticsearch CPU requests"
  type        = string
  default     = "1000m"
}

variable "elasticsearch_memory_limits" {
  description = "Elasticsearch memory limits"
  type        = string
  default     = "8Gi"
}

variable "elasticsearch_cpu_limits" {
  description = "Elasticsearch CPU limits"
  type        = string
  default     = "2000m"
}

# Kibana Configuration
variable "kibana_version" {
  description = "Kibana version"
  type        = string
  default     = "8.11.0"
}

variable "kibana_replicas" {
  description = "Number of Kibana replicas"
  type        = number
  default     = 1
}

variable "kibana_memory_requests" {
  description = "Kibana memory requests"
  type        = string
  default     = "2Gi"
}

variable "kibana_cpu_requests" {
  description = "Kibana CPU requests"
  type        = string
  default     = "500m"
}

variable "kibana_memory_limits" {
  description = "Kibana memory limits"
  type        = string
  default     = "4Gi"
}

variable "kibana_cpu_limits" {
  description = "Kibana CPU limits"
  type        = string
  default     = "1000m"
}

# Grafana Configuration
variable "grafana_version" {
  description = "Grafana version"
  type        = string
  default     = "10.2.0"
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "grafana_memory_requests" {
  description = "Grafana memory requests"
  type        = string
  default     = "1Gi"
}

variable "grafana_cpu_requests" {
  description = "Grafana CPU requests"
  type        = string
  default     = "250m"
}

variable "grafana_memory_limits" {
  description = "Grafana memory limits"
  type        = string
  default     = "2Gi"
}

variable "grafana_cpu_limits" {
  description = "Grafana CPU limits"
  type        = string
  default     = "500m"
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "elastic-stack"
    ManagedBy   = "terraform"
    Cloud       = "azure"
  }
}
