# Azure Staging Environment Outputs

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the Azure Resource Group"
  value       = azurerm_resource_group.main.location
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.azure_aks.cluster_name
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.azure_aks.cluster_fqdn
}

output "cluster_private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = module.azure_aks.cluster_private_fqdn
}

output "kube_config_host" {
  description = "Kubernetes cluster host"
  value       = module.azure_aks.kube_config_host
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.azure_aks.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.azure_aks.log_analytics_workspace_name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.azure_aks.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.azure_aks.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.azure_aks.key_vault_uri
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.azure_aks.application_gateway_public_ip
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = module.azure_aks.container_registry_name
}

output "container_registry_login_server" {
  description = "Login server of the Container Registry"
  value       = module.azure_aks.container_registry_login_server
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.azure_networking.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.azure_networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.azure_networking.aks_subnet_id
}

output "gateway_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = module.azure_networking.gateway_subnet_id
}

# Service URLs
output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "http://${kubernetes_service.elasticsearch.metadata[0].name}.${kubernetes_service.elasticsearch.metadata[0].namespace}.svc.cluster.local:9200"
}

output "kibana_url" {
  description = "Kibana URL (external)"
  value       = "http://${kubernetes_service.kibana.status[0].load_balancer[0].ingress[0].ip}:5601"
}

output "grafana_url" {
  description = "Grafana URL (external)"
  value       = "http://${kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip}:3000"
}

# Access Information
output "access_information" {
  description = "Access information for the deployed services"
  value = {
    elasticsearch = {
      internal_url = "http://${kubernetes_service.elasticsearch.metadata[0].name}.${kubernetes_service.elasticsearch.metadata[0].namespace}.svc.cluster.local:9200"
      external_url = "Use port-forward: kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
    }
    kibana = {
      external_url = "http://${kubernetes_service.kibana.status[0].load_balancer[0].ingress[0].ip}:5601"
      internal_url = "http://${kubernetes_service.kibana.metadata[0].name}.${kubernetes_service.kibana.metadata[0].namespace}.svc.cluster.local:5601"
    }
    grafana = {
      external_url = "http://${kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip}:3000"
      internal_url = "http://${kubernetes_service.grafana.metadata[0].name}.${kubernetes_service.grafana.metadata[0].namespace}.svc.cluster.local:3000"
      username     = "admin"
      password     = var.grafana_admin_password
    }
  }
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for the Azure resources"
  value = {
    aks_cluster = "$0 (control plane is free)"
    worker_nodes = "$${var.node_count} x ${var.node_vm_size} = ~$${var.node_count * 120}-$${var.node_count * 200}/month"
    application_gateway = "~$20-50/month"
    container_registry = "~$5/month"
    key_vault = "~$1/month"
    log_analytics = "~$10-30/month"
    total_estimated = "~$${var.node_count * 120 + 35}-$${var.node_count * 200 + 85}/month"
  }
}
