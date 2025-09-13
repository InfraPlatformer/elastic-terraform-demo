# Development Environment Configuration
# Copy of staging configuration for development

# EKS Configuration
cluster_version = "1.29"
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    desired_size = 2
    max_size = 3
    min_size = 1
    disk_size = 50
    labels = {
      role = "elasticsearch"
    }
    taints = []  # No taints to allow system pods like CoreDNS
  }
}

# Networking Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Tags
environment = "development"
project = "elastic-stack"
managed_by = "terraform"