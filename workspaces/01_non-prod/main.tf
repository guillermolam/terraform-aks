# Dev environment AKS cluster configuration

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Variables for the dev environment
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "client_id" {
  description = "Service Principal (app) client ID"
  type        = string
}

variable "client_secret" {
  description = "Service Principal client secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "switzerlandnorth"
}

# Dev environment specific variables
locals {
  environment         = "dev"
  name                = "aks-${local.environment}"
  resource_group_name = "rg-${local.name}"
  vnet_address_space  = "10.0.0.0/16"
  subnets             = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  agent_count         = 2
  agent_vm_size       = "Standard_D2s_v3"
  kubernetes_version  = "1.26.0"
  dns_service_ip      = "10.0.0.10"
  service_cidr        = "10.0.0.0/16"
  docker_bridge_cidr  = "172.17.0.1/16"
  availability_zones  = [1, 2, 3]
}

# Network module
module "network" {
  source = "../../modules/01. network"

  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  location            = var.location
  name                = local.name
  resource_group_name = local.resource_group_name
  agent_vm_size       = local.agent_vm_size
  agent_count         = local.agent_count
  subnets             = local.subnets

}

# IAM module
module "iam" {
  source = "../../modules/02. iam"

  client_id            = var.client_id
  resource_group_id    = module.network.resource_group_id
  role_definition_name = "Contributor"
  principal_type       = "ServicePrincipal"
}

# AKS module
module "aks" {
  source = "../../modules/03. aks"
  agent_count         = local.agent_count
  agent_vm_size       = local.agent_vm_size
  subnets = module.network.subnets 
  depends_on = [
    module.network,
    module.iam
  ]
}

# Outputs
output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.aks_cluster_name
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.fqdn
}
