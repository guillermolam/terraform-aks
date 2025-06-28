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
