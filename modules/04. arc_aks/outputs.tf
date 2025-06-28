output "aks_cluster_name" {
  description = "The name of the Arc-enabled Kubernetes cluster"
  value       = azurerm_arc_kubernetes_cluster.arc.name
}

output "node_resource_group" {
  description = "The automatically created resource group for Arc-enabled Kubernetes nodes"
  value       = azurerm_arc_kubernetes_cluster.arc.resource_group_name
}

# Commented out to avoid duplicate output definition with kubeconfig_output.tf
# output "kube_config_raw" {
#   description = "Raw kubeconfig content for the Arc-enabled Kubernetes cluster"
#   value       = azurerm_kubernetes_cluster.arc_aks.kube_config_raw
#   sensitive   = true
# }

output "fqdn" {
  description = "The fully qualified domain name for the Arc-enabled Kubernetes API server"
  value       = azurerm_arc_kubernetes_cluster.arc.name
}
