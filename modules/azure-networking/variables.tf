# Azure Networking Module Variables

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster (used for naming resources)"
  type        = string
  default     = "elastic-aks"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US 2"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR block for the AKS subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "gateway_subnet_cidr" {
  description = "CIDR block for the Application Gateway subnet"
  type        = list(string)
  default     = ["10.1.2.0/24"]
}

variable "firewall_subnet_cidr" {
  description = "CIDR block for the Azure Firewall subnet"
  type        = list(string)
  default     = ["10.1.3.0/24"]
}

variable "enable_firewall" {
  description = "Enable Azure Firewall"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "elastic-stack"
    ManagedBy   = "terraform"
  }
}
