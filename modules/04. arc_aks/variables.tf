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
