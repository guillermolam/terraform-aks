variable "cluster_name" {
  type        = string
  description = "Name of your Arc-enabled cluster"
}

variable "location" {
  type        = string
  description = "Azure region to place the Arc resource metadata (metadata-only)"
}

variable "resource_group_name" {
  type        = string
  description = "Azure RG housing the Arc resource"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version string matching your on-prem cluster"
}

variable "kube_config" {
  type        = string
  description = "Full kubeconfig YAML of the existing on-prem cluster"
}

variable "kube_config_context" {
  type        = string
  description = "The context name from the kubeconfig to use"
}

variable "agent_public_key_certificate" {
  type        = string
  description = "Public key certificate for the cluster agent"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Arc resources"
  default     = {}
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to the kubeconfig file for Helm provider"
  default     = "~/.kube/config"
}

variable "cert_manager_namespace" {
  type        = string
  description = "Namespace for cert-manager"
  default     = "cert-manager"
}

variable "cert_manager_release_name" {
  type        = string
  description = "Release name for cert-manager Helm chart"
  default     = "cert-manager"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Version of cert-manager Helm chart"
  default     = "v1.11.0"
}

variable "ingress_namespace" {
  type        = string
  description = "Namespace for NGINX Ingress Controller"
  default     = "ingress-nginx"
}

variable "ingress_release_name" {
  type        = string
  description = "Release name for NGINX Ingress Controller Helm chart"
  default     = "ingress-nginx"
}

variable "ingress_chart_version" {
  type        = string
  description = "Version of NGINX Ingress Controller Helm chart"
  default     = "4.5.2"
}

variable "cluster_issuer_name" {
  type        = string
  description = "Name of the ClusterIssuer for cert-manager"
  default     = "letsencrypt-prod"
}

variable "acme_server" {
  type        = string
  description = "ACME server URL for cert-manager"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme_email" {
  type        = string
  description = "Email address for ACME account"
  default     = "user@example.com"
}

variable "cluster_issuer_secret_name" {
  type        = string
  description = "Secret name for storing ACME private key"
  default     = "letsencrypt-prod-key"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class for NGINX"
  default     = "nginx"
}

variable "ingress_name" {
  type        = string
  description = "Name of the Ingress resource"
  default     = "app-ingress"
}

variable "ingress_hosts" {
  type        = list(string)
  description = "List of hostnames for the Ingress"
  default     = ["example.com"]
}

variable "tls_secret_name" {
  type        = string
  description = "Secret name for storing TLS certificate"
  default     = "app-tls"
}

variable "service_name" {
  type        = string
  description = "Name of the backend service for Ingress"
  default     = "app-service"
}

variable "service_port" {
  type        = number
  description = "Port number of the backend service"
  default     = 80
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure Client ID for Service Principal"
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret for Service Principal"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}
