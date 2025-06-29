output "kube_config_raw" {
  description = "Raw kubeconfig content for the Arc-enabled Kubernetes cluster"
  value       = "" # Placeholder: Arc-enabled clusters may not provide direct kubeconfig
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw admin kubeconfig content for the Arc-enabled Kubernetes cluster"
  value       = "" # Placeholder: Arc-enabled clusters may not provide direct admin kubeconfig
  sensitive   = true
}

output "kube_config_host" {
  description = "Kubernetes API server host from kubeconfig for Arc-enabled cluster"
  value       = "" # Placeholder: Arc-enabled clusters may not provide direct host information
}
