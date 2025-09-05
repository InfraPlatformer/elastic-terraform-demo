# Simple Development Environment Configuration (AWS Only)
environment = "development"
cluster_name = "elasticsearch-dev-aws"
cluster_version = "1.29"

# AWS EKS Configuration
aws_region = "us-west-2"

# Node Groups for Development (smaller instances)
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    desired_size = 2
    max_size = 3
    min_size = 1
    disk_size = 50
  }
  monitoring = {
    instance_types = ["t3.small"]
    capacity_type = "ON_DEMAND"
    desired_size = 1
    max_size = 2
    min_size = 1
    disk_size = 20
  }
}

# Elasticsearch Configuration
elasticsearch_replicas = 1

# Security Configuration (disabled for development)
enable_security = false
enable_ssl = false

# Backup Configuration (disabled for development)
enable_backup = false

# Cost Optimization
enable_spot_instances = false
enable_auto_scaling = true
