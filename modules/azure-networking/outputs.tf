# Azure Networking Module Outputs

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet"
  value       = azurerm_subnet.aks.name
}

output "aks_subnet_address_prefixes" {
  description = "Address prefixes of the AKS subnet"
  value       = azurerm_subnet.aks.address_prefixes
}

output "gateway_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.gateway.id
}

output "gateway_subnet_name" {
  description = "Name of the Application Gateway subnet"
  value       = azurerm_subnet.gateway.name
}

output "gateway_subnet_address_prefixes" {
  description = "Address prefixes of the Application Gateway subnet"
  value       = azurerm_subnet.gateway.address_prefixes
}

output "firewall_subnet_id" {
  description = "ID of the Azure Firewall subnet"
  value       = var.enable_firewall ? azurerm_subnet.firewall[0].id : null
}

output "firewall_subnet_name" {
  description = "Name of the Azure Firewall subnet"
  value       = var.enable_firewall ? azurerm_subnet.firewall[0].name : null
}

output "aks_nsg_id" {
  description = "ID of the AKS Network Security Group"
  value       = azurerm_network_security_group.aks.id
}

output "aks_nsg_name" {
  description = "Name of the AKS Network Security Group"
  value       = azurerm_network_security_group.aks.name
}

output "gateway_nsg_id" {
  description = "ID of the Application Gateway Network Security Group"
  value       = azurerm_network_security_group.gateway.id
}

output "gateway_nsg_name" {
  description = "Name of the Application Gateway Network Security Group"
  value       = azurerm_network_security_group.gateway.name
}

output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = var.enable_firewall ? azurerm_firewall.main[0].id : null
}

output "firewall_name" {
  description = "Name of the Azure Firewall"
  value       = var.enable_firewall ? azurerm_firewall.main[0].name : null
}

output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall"
  value       = var.enable_firewall ? azurerm_public_ip.firewall[0].ip_address : null
}

output "route_table_id" {
  description = "ID of the AKS Route Table"
  value       = azurerm_route_table.aks.id
}

output "route_table_name" {
  description = "Name of the AKS Route Table"
  value       = azurerm_route_table.aks.name
}

output "private_dns_zone_id" {
  description = "ID of the Private DNS Zone"
  value       = azurerm_private_dns_zone.aks.id
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS Zone"
  value       = azurerm_private_dns_zone.aks.name
}
