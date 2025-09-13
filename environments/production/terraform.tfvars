# Production Environment Configuration
# Enhanced configuration for production

# EKS Configuration
cluster_version = "1.29"
aws_node_groups = {
  elasticsearch = {
    instance_types = ["m5.large"]
    capacity_type = "ON_DEMAND"
    desired_size = 5
    max_size = 10
    min_size = 3
    disk_size = 200
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
environment = "production"
project = "elastic-stack"
managed_by = "terraform"