provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_arc_kubernetes_cluster" "arc" {
  name                         = var.cluster_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  agent_public_key_certificate = var.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_arc_kubernetes_provisioned_cluster" "arcprov" {
  name                = azurerm_arc_kubernetes_cluster.arc.name
  location            = azurerm_arc_kubernetes_cluster.arc.location
  resource_group_name = azurerm_arc_kubernetes_cluster.arc.resource_group_name
  # kubernetes_version is automatically determined

  identity {
    type = "SystemAssigned"
  }
}

# Optional extensions (e.g., monitoring, policy, ingress, etc.)
resource "azurerm_arc_kubernetes_cluster_extension" "monitoring" {
  name           = "monitoring"
  cluster_id     = azurerm_arc_kubernetes_cluster.arc.id
  extension_type = "AzureMonitorContainers"

  identity {
    type = "SystemAssigned"
  }
}

output "arc_cluster_name" {
  description = "Name of the Arc-enabled Kubernetes cluster"
  value       = azurerm_arc_kubernetes_cluster.arc.name
}

output "arc_provisioned_id" {
  description = "ID of the provisioned Arc Kubernetes cluster resource"
  value       = azurerm_arc_kubernetes_provisioned_cluster.arcprov.id
}
