# =============================================================================
# DEVELOPMENT ENVIRONMENT OUTPUTS
# =============================================================================

# AWS Infrastructure Outputs
output "aws_cluster_info" {
  description = "AWS EKS cluster information"
  value = {
    name     = module.aws_eks.cluster_name
    endpoint = module.aws_eks.cluster_endpoint
    version  = module.aws_eks.cluster_version
    region   = var.aws_region
    arn      = module.aws_eks.cluster_arn
  }
}

output "aws_networking_info" {
  description = "AWS networking information"
  value = {
    vpc_id          = module.aws_networking.vpc_id
    vpc_cidr        = module.aws_networking.vpc_cidr
    public_subnets  = module.aws_networking.public_subnets
    private_subnets = module.aws_networking.private_subnets
  }
}

# Connection Instructions
output "connection_instructions" {
  description = "Instructions for connecting to the infrastructure"
  value = {
    kubectl_config = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.aws_eks.cluster_name}"
    elasticsearch_url = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
    port_forward_command = "kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
  }
}

# Project Information
output "project_info" {
  description = "Project information"
  value = {
    name        = var.project_name
    environment = var.environment
    owner       = var.owner
    region      = var.aws_region
    version     = "1.0.0"
    managed_by  = "terraform"
  }
}
