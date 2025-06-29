# Ngrok module for secure tunneling to Kubernetes services

provider "ngrok" {
  api_key = var.ngrok_api_key
}

resource "ngrok_tunnel_group_backend" "k8s_services" {
  labels = {
    environment = var.environment
    service     = var.service_name
  }
  
  description = "Backend group for Kubernetes services in ${var.environment} environment"
}

resource "ngrok_tls_certificate" "k8s_tls" {
  certificate_pem = var.tls_certificate_pem
  private_key_pem = var.tls_private_key_pem
  description     = "TLS certificate for Kubernetes ingress in ${var.environment} environment"
}

output "tunnel_group_id" {
  description = "ID of the tunnel group backend for Kubernetes services"
  value       = ngrok_tunnel_group_backend.k8s_services.id
}

output "tls_certificate_id" {
  description = "ID of the TLS certificate for Kubernetes ingress"
  value       = ngrok_tls_certificate.k8s_tls.id
}
