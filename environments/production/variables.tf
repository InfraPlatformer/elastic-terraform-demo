# Production Environment Variables

variable "cluster_version" {
  description = "Kubernetes cluster version"
  type        = string
  default     = "1.29"
}

variable "aws_node_groups" {
  description = "AWS EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    max_size       = number
    min_size       = number
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    elasticsearch = {
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 3
      max_size       = 10
      desired_size   = 5
      disk_size      = 200
      labels = {
        role = "elasticsearch"
      }
      taints = []
    }
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}