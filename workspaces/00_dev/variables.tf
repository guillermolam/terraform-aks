variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file for the on-premises Kubernetes cluster"
  default     = "~/.kube/config"
}

variable "kube_config_context" {
  type        = string
  description = "The context name from the kubeconfig to use"
  default     = "rancher-desktop"
}

variable "ngrok_api_key" {
  description = "API key for authenticating with ngrok"
  type        = string
  sensitive   = true
}

variable "tls_certificate_pem" {
  description = "PEM-encoded TLS certificate for secure connections"
  type        = string
  sensitive   = true
}

variable "tls_private_key_pem" {
  description = "PEM-encoded private key for the TLS certificate"
  type        = string
  sensitive   = true
}
