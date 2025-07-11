output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "node_resource_group" {
  description = "The automatically created resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "fqdn" {
  description = "The fully qualified domain name for the Kubernetes API server"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}
