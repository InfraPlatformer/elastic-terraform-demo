# Development Environment Configuration
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

# Security and Access
enable_public_access = true
allowed_cidr_blocks = ["0.0.0.0/0"]

# Storage
enable_ebs_csi_driver = true
