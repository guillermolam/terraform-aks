# Non-prod environment AKS cluster configuration

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

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

# Non-prod environment specific variables
locals {
  environment           = "non-prod"
  name                  = "aks-${local.environment}"
  resource_group_name   = "rg-${local.name}"
  vnet_name             = "vnet-${local.name}"
  address_space         = ["10.0.0.0/16"]
  subnets               = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  agent_count           = 2
  agent_vm_size         = "Standard_D2s_v3"
  agent_min_count       = 2
  agent_max_count       = 4
  agent_max_pods        = 110
  agent_os_disk_size_gb = 30
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
  vnet_name           = local.vnet_name
  address_space       = local.address_space
  subnet_configs = [
    { name = "public-subnet-1", prefix = "10.0.1.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "public-subnet-2", prefix = "10.0.2.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "private-subnet-1", prefix = "10.0.3.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "private-subnet-2", prefix = "10.0.4.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] }
  ]
}

# IAM module
module "iam" {
  source = "../../modules/02. iam"

  client_id            = var.client_id
  resource_group_id    = module.network.resource_group_id
  role_definition_name = "Contributor"
  principal_type       = "ServicePrincipal"
}

# Arc AKS module for non-prod environment
module "arc_aks" {
  source = "../../modules/04. arc_aks"

  cluster_name                 = local.name
  location                     = var.location
  resource_group_name          = local.resource_group_name
  kubernetes_version           = "1.26.0"
  agent_public_key_certificate = "cGxhY2Vob2xkZXI=" # Base64 encoded placeholder
  kube_config                  = ""
  kube_config_context          = ""
  tags                         = {}
  subscription_id              = var.subscription_id
  client_id                    = var.client_id
  client_secret                = var.client_secret
  tenant_id                    = var.tenant_id

  # Note: depends_on removed due to legacy module constraints
}

# Outputs
output "arc_cluster_name" {
  description = "Name of the Arc-enabled Kubernetes cluster"
  value       = module.arc_aks.arc_cluster_name
}

output "arc_provisioned_id" {
  description = "ID of the provisioned Arc Kubernetes cluster resource"
  value       = module.arc_aks.arc_provisioned_id
}
