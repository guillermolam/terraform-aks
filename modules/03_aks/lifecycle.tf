# Lifecycle configuration for AKS cluster
# This file contains lifecycle rules for the azurerm_kubernetes_cluster resource
# Note: This extends the resource defined in aks.tf

resource "azurerm_kubernetes_cluster" "aks" {
  # No need to redefine required attributes as they are in aks.tf
  lifecycle {
    ignore_changes = [
      # Ignore changes to node count as it might be adjusted manually or by autoscaling
      default_node_pool[0].node_count,
    ]
  }
}
