# Development Environment Configuration (AWS Only)
environment = "development"
cluster_name = "elasticsearch-dev-aws"
cluster_version = "1.29"
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
elasticsearch_data_nodes = 2
elasticsearch_master_nodes = 1
elasticsearch_ingest_nodes = 1
elasticsearch_heap_size = "2g"

# Kibana Configuration
kibana_replicas = 1

# Security and Access
enable_public_access = true
allowed_cidr_blocks = ["0.0.0.0/0"]

# Storage
enable_ebs_csi_driver = true

# Multi-Cloud Configuration (AWS Only for Development)
enable_aws_deployment = true
enable_azure_deployment = false
