variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "elasticsearch_url" {
  description = "URL to connect to Elasticsearch"
  type        = string
}

variable "kibana_url" {
  description = "URL to connect to Kibana"
  type        = string
} 