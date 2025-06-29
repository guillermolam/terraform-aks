output "tunnel_group_id" {
  description = "ID of the tunnel group backend for Kubernetes services"
  value       = ngrok_tunnel_group_backend.k8s_services.id
}

output "tls_certificate_id" {
  description = "ID of the TLS certificate for Kubernetes ingress"
  value       = ngrok_tls_certificate.k8s_tls.id
}
