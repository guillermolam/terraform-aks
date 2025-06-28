provider "azurerm" {
  features {}
  # Updated to align with Terraform provider version 4.34.0 for Azure Arc Kubernetes
}

module "arc_aks" {
  source = "../../modules/04. arc_aks"

  cluster_name                 = var.cluster_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  kubernetes_version           = var.kubernetes_version
  agent_public_key_certificate = var.agent_public_key_certificate
  kube_config                  = var.kube_config
  kube_config_context          = var.kube_config_context
  tags                         = var.tags
}

output "arc_cluster_name" {
  description = "Name of the Arc-enabled Kubernetes cluster"
  value       = module.arc_aks.arc_cluster_name
}

output "arc_provisioned_id" {
  description = "ID of the provisioned Arc Kubernetes cluster resource"
  value       = module.arc_aks.arc_provisioned_id
}
