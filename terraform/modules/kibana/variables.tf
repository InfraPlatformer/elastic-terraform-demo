variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "kibana_version" {
  description = "Kibana version to deploy"
  type        = string
  default     = "8.11.0"
}

variable "replicas" {
  description = "Number of Kibana replicas"
  type        = number
  default     = 2
}

variable "storage_size" {
  description = "Storage size for Kibana PVC"
  type        = string
  default     = "10Gi"
}

variable "memory_limit" {
  description = "Memory limit for Kibana pods"
  type        = string
  default     = "1Gi"
}

variable "cpu_limit" {
  description = "CPU limit for Kibana pods"
  type        = string
  default     = "500m"
}

variable "enable_tls" {
  description = "Enable TLS encryption for Kibana"
  type        = bool
  default     = true
}

variable "elasticsearch_url" {
  description = "URL to connect to Elasticsearch"
  type        = string
}

variable "kibana_password" {
  description = "Password for kibana user"
  type        = string
  sensitive   = true
}

variable "node_selector" {
  description = "Node selector for Kibana pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for Kibana pods"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "enable_ingress" {
  description = "Enable ingress for Kibana"
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Enable horizontal pod autoscaling for Kibana"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum number of Kibana replicas for autoscaling"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of Kibana replicas for autoscaling"
  type        = number
  default     = 5
} 