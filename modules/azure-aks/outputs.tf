# =============================================================================
# AZURE AKS MODULE OUTPUTS
# =============================================================================

output "cluster_id" {
  description = "The AKS cluster ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "The AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_endpoint" {
  description = "The AKS cluster endpoint"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "The AKS cluster certificate authority data"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "cluster_identity" {
  description = "The AKS cluster identity"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_resource_group.aks.name
}

output "resource_group_id" {
  description = "The resource group ID"
  value       = azurerm_resource_group.aks.id
}

output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.aks.location
}

output "vnet_id" {
  description = "The virtual network ID"
  value       = azurerm_virtual_network.aks.id
}

output "vnet_name" {
  description = "The virtual network name"
  value       = azurerm_virtual_network.aks.name
}

output "subnet_id" {
  description = "The subnet ID"
  value       = azurerm_subnet.aks.id
}

output "subnet_name" {
  description = "The subnet name"
  value       = azurerm_subnet.aks.name
}

output "node_pools" {
  description = "The AKS node pools"
  value = {
    default = azurerm_kubernetes_cluster.main.default_node_pool
    additional = azurerm_kubernetes_cluster_node_pool.additional
  }
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.aks.id
}

output "container_registry_id" {
  description = "The Azure Container Registry ID"
  value       = var.enable_container_registry ? azurerm_container_registry.aks[0].id : null
}

output "container_registry_login_server" {
  description = "The Azure Container Registry login server"
  value       = var.enable_container_registry ? azurerm_container_registry.aks[0].login_server : null
}

output "kube_config" {
  description = "The complete kubeconfig for the AKS cluster"
  value = {
    host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
    cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
    client_certificate     = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
    client_key             = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  }
  sensitive = true
}

output "network_profile" {
  description = "The AKS network profile"
  value       = azurerm_kubernetes_cluster.main.network_profile
}

output "addon_profile" {
  description = "The AKS addon profile"
  value       = azurerm_kubernetes_cluster.main.addon_profile
}
