# =============================================================================
# AZURE AKS CLUSTER MODULE
# =============================================================================

# Azure Resource Group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-rg"
    Type = "AKS Resource Group"
  })
}

# Azure Virtual Network
resource "azurerm_virtual_network" "aks" {
  name                = "${var.cluster_name}-vnet"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  address_space       = var.vnet_address_space

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-vnet"
    Type = "AKS Virtual Network"
  })
}

# Azure Subnets
resource "azurerm_subnet" "aks" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = var.subnet_address_prefixes
}

# Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name                = "default"
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    count               = var.default_node_pool.count
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vnet_subnet_id      = azurerm_subnet.aks.id
    type                = "VirtualMachineScaleSets"
    node_labels         = var.default_node_pool.node_labels
    node_taints         = var.default_node_pool.node_taints
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  addon_profile {
    azure_policy {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}"
    Type = "AKS Cluster"
  })
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  node_count            = each.value.count
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  vnet_subnet_id        = azurerm_subnet.aks.id
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-${each.key}-np"
    Type = "AKS Node Pool"
  })
}

# Log Analytics Workspace for Monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-logs"
    Type = "Log Analytics Workspace"
  })
}

# Azure Container Registry (Optional)
resource "azurerm_container_registry" "aks" {
  count               = var.enable_container_registry ? 1 : 0
  name                = "${replace(var.cluster_name, "-", "")}acr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-acr"
    Type = "Container Registry"
  })
}

# Network Security Group
resource "azurerm_network_security_group" "aks" {
  name                = "${var.cluster_name}-nsg"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.cluster_name}-nsg"
    Type = "Network Security Group"
  })
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}
