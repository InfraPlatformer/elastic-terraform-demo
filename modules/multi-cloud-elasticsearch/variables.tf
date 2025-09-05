# =============================================================================
# MULTI-CLOUD ELASTICSEARCH MODULE VARIABLES
# =============================================================================

variable "cluster_name" {
  description = "Name of the Elasticsearch cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Elasticsearch"
  type        = string
  default     = "elasticsearch"
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

# Cloud Deployment Flags
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

# Cluster References
variable "aws_eks_cluster" {
  description = "AWS EKS cluster module reference"
  type        = any
}

variable "azure_aks_cluster" {
  description = "Azure AKS cluster module reference"
  type        = any
}

# Elasticsearch Configuration
variable "elasticsearch_replicas" {
  description = "Number of Elasticsearch replicas per cloud"
  type        = number
  default     = 3
}

variable "elasticsearch_image" {
  description = "Elasticsearch Docker image"
  type        = string
  default     = "docker.elastic.co/elasticsearch/elasticsearch"
}

variable "elasticsearch_version" {
  description = "Elasticsearch version"
  type        = string
  default     = "8.11.0"
}

variable "elasticsearch_seed_hosts" {
  description = "Comma-separated list of Elasticsearch seed hosts"
  type        = string
}

variable "elasticsearch_initial_master_nodes" {
  description = "Comma-separated list of initial master nodes"
  type        = string
}

variable "elasticsearch_java_opts" {
  description = "Java options for Elasticsearch"
  type        = string
  default     = "-Xms2g -Xmx2g"
}

# Resource Requirements
variable "elasticsearch_memory_request" {
  description = "Memory request for Elasticsearch pods"
  type        = string
  default     = "2Gi"
}

variable "elasticsearch_cpu_request" {
  description = "CPU request for Elasticsearch pods"
  type        = string
  default     = "1000m"
}

variable "elasticsearch_memory_limit" {
  description = "Memory limit for Elasticsearch pods"
  type        = string
  default     = "4Gi"
}

variable "elasticsearch_cpu_limit" {
  description = "CPU limit for Elasticsearch pods"
  type        = string
  default     = "2000m"
}

# Storage Configuration
variable "enable_persistent_storage" {
  description = "Enable persistent storage for Elasticsearch"
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = ""
}

variable "storage_size" {
  description = "Storage size for persistent volumes"
  type        = string
  default     = "100Gi"
}

# Security Configuration
variable "enable_security" {
  description = "Enable Elasticsearch security features"
  type        = bool
  default     = true
}

variable "elasticsearch_password" {
  description = "Elasticsearch password"
  type        = string
  sensitive   = true
  default     = ""
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring for Elasticsearch"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 30
}

# Network Configuration
variable "service_type" {
  description = "Kubernetes service type"
  type        = string
  default     = "ClusterIP"
}

variable "load_balancer_ip" {
  description = "Load balancer IP (for LoadBalancer service type)"
  type        = string
  default     = ""
}

# Labels and Annotations
variable "additional_labels" {
  description = "Additional labels to apply to Elasticsearch resources"
  type        = map(string)
  default     = {}
}

variable "additional_annotations" {
  description = "Additional annotations to apply to Elasticsearch resources"
  type        = map(string)
  default     = {}
}
