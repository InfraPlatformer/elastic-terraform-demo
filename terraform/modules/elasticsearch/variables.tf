variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "elasticsearch_version" {
  description = "Elasticsearch version to deploy"
  type        = string
  default     = "8.11.0"
}

variable "replicas" {
  description = "Number of Elasticsearch replicas"
  type        = number
  default     = 3
}

variable "storage_size" {
  description = "Storage size for Elasticsearch PVC"
  type        = string
  default     = "100Gi"
}

variable "memory_limit" {
  description = "Memory limit for Elasticsearch pods"
  type        = string
  default     = "2Gi"
}

variable "cpu_limit" {
  description = "CPU limit for Elasticsearch pods"
  type        = string
  default     = "1000m"
}

variable "enable_tls" {
  description = "Enable TLS encryption for Elasticsearch"
  type        = bool
  default     = true
}

variable "elastic_password" {
  description = "Password for elastic user"
  type        = string
  sensitive   = true
}

variable "node_selector" {
  description = "Node selector for Elasticsearch pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for Elasticsearch pods"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "enable_ingress" {
  description = "Enable ingress for Elasticsearch"
  type        = bool
  default     = false
} 