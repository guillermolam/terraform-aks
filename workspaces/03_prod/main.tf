# Production environment AKS cluster configuration

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

# Production environment specific variables
locals {
  environment         = "prod"
  name                = "aks-${local.environment}"
  resource_group_name = "rg-${local.name}"
  vnet_name           = "vnet-${local.name}"
  address_space       = ["10.2.0.0/16"]
  subnets             = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24"]
  agent_count         = 3
  agent_vm_size       = "Standard_D2s_v3"
  agent_min_count     = 3
  agent_max_count     = 6
  agent_max_pods      = 110
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
  subnet_configs      = [
    { name = "public-subnet-1", prefix = "10.2.1.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "public-subnet-2", prefix = "10.2.2.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "private-subnet-1", prefix = "10.2.3.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] },
    { name = "private-subnet-2", prefix = "10.2.4.0/24", service_endpoints = [], service_endpoint_policy_ids = [], default_outbound_access = true, delegations = [] }
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

# AKS module
module "aks" {
  source = "../../modules/03. aks"

  aks_cluster_name    = local.name
  location            = var.location
  resource_group_name = local.resource_group_name
  agent_vm_size       = local.agent_vm_size
  agent_count         = local.agent_count
  vnet_subnet_id      = module.network.subnets["public-subnet-1"].id
  agent_min_count     = local.agent_min_count
  agent_max_count     = local.agent_max_count
  agent_max_pods      = local.agent_max_pods
  agent_os_disk_size_gb = local.agent_os_disk_size_gb
  agent_subnet_id     = module.network.subnets["public-subnet-1"].id
  kubeconfig_path     = "~/.kube/config"
  log_analytics_workspace_id = ""
  ingress_name        = "aks-ingress"
  ingress_hosts       = ["aks-prod.example.com"]
  tls_secret_name     = "aks-tls-secret"
  service_name        = "aks-service"
  acme_email          = "admin@example.com"
  auto_scaler_profile_balance_similar_node_groups = false
  auto_scaler_profile_empty_bulk_delete_max = 10
  auto_scaler_profile_expander = "random"
  auto_scaler_profile_max_graceful_termination_sec = 600
  auto_scaler_profile_max_node_provisioning_time = "15m"
  auto_scaler_profile_max_unready_nodes = 3
  auto_scaler_profile_max_unready_percentage = 45
  auto_scaler_profile_new_pod_scale_up_delay = 0
  auto_scaler_profile_scale_down_delay_after_add = "10m"
  auto_scaler_profile_scale_down_delay_after_delete = "20s"
  auto_scaler_profile_scale_down_delay_after_failure = "3m"
  auto_scaler_profile_scale_down_unneeded = true
  auto_scaler_profile_scale_down_unready = true
  auto_scaler_profile_scale_down_utilization_threshold = 0.5
  auto_scaler_profile_scan_interval = "10s"
  auto_scaler_profile_skip_nodes_with_local_storage = false
  auto_scaler_profile_skip_nodes_with_system_pods = true

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
