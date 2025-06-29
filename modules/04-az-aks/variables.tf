
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}
variable "location" {
  description = "Azure region for AKS deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "agent_vm_size" {
  description = "VM size for AKS agent pool"
  type        = string
}

variable "agent_count" {
  description = "Number of nodes in the AKS agent pool"
  type        = number
}

variable "vnet_subnet_id" {
  description = "ID of the subnet for AKS node pool"
  type        = string
}

variable "admin_group_object_ids" {
  description = "Object IDs of admin groups for AKS RBAC"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to AKS resources"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_path" {
  description = "Path to save the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "ingress_namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_release_name" {
  description = "Release name for NGINX Ingress Controller Helm chart"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_chart_version" {
  description = "Version of NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.5.2"
}
variable "agent_min_count" {
  description = "Minimum nodes in the default node pool"
  type        = number
}
variable "agent_max_count" {
  description = "Maximum nodes in the default node pool"
  type        = number
}
variable "agent_max_pods" {
  description = "Maximum pods per node to limit blast radius"
  type        = number
}
variable "agent_os_disk_size_gb" {
  description = "OS disk size for nodes in GB"
  type        = number
}
variable "agent_subnet_id" {
  description = "VNet subnet ID for the default node pool"
  type        = string
}
variable "agent_labels" {
  description = "Node labels for default node pool"
  type        = map(string)
  default     = {}
}

// Autoscaler Profile
variable "auto_scaler_profile_balance_similar_node_groups" {
  description = "Auto-scaler: balance similar node groups setting"
  type        = bool
}
variable "auto_scaler_profile_empty_bulk_delete_max" {
  description = "Auto-scaler: max empty bulk delete"
  type        = number
}
variable "auto_scaler_profile_expander" {
  description = "Auto-scaler expander strategy"
  type        = string
}
variable "auto_scaler_profile_max_graceful_termination_sec" {
  description = "Auto-scaler: max graceful termination seconds"
  type        = number
}
variable "auto_scaler_profile_max_node_provisioning_time" {
  description = "Auto-scaler: max node provisioning time"
  type        = string
}
variable "auto_scaler_profile_max_unready_nodes" {
  description = "Auto-scaler: max unready nodes"
  type        = number
}
variable "auto_scaler_profile_max_unready_percentage" {
  description = "Auto-scaler: max unready percentage"
  type        = number
}
variable "auto_scaler_profile_new_pod_scale_up_delay" {
  description = "Auto-scaler: new pod scale-up delay in seconds"
  type        = number
}
variable "auto_scaler_profile_scale_down_delay_after_add" {
  description = "Auto-scaler: scale-down delay after add"
  type        = string
}
variable "auto_scaler_profile_scale_down_delay_after_delete" {
  description = "Auto-scaler: scale-down delay after delete"
  type        = string
}
variable "auto_scaler_profile_scale_down_delay_after_failure" {
  description = "Auto-scaler: scale-down delay after failure"
  type        = string
}
variable "auto_scaler_profile_scale_down_unneeded" {
  description = "Auto-scaler: whether to scale down unneeded"
  type        = bool
}
variable "auto_scaler_profile_scale_down_unready" {
  description = "Auto-scaler: whether to scale down unready"
  type        = bool
}
variable "auto_scaler_profile_scale_down_utilization_threshold" {
  description = "Auto-scaler: utilization threshold for scale-down"
  type        = number
}
variable "auto_scaler_profile_scan_interval" {
  description = "Auto-scaler: scan interval"
  type        = string
}
variable "auto_scaler_profile_skip_nodes_with_local_storage" {
  description = "Auto-scaler: skip nodes with local storage"
  type        = bool
}
variable "auto_scaler_profile_skip_nodes_with_system_pods" {
  description = "Auto-scaler: skip nodes with system pods"
  type        = bool
}

// KEDA/VPA Profile
variable "workload_autoscaler_profile" {
  description = "KEDA/VPA profile settings"
  type = object({
    keda_enabled                    = bool
    vertical_pod_autoscaler_enabled = bool
  })
  default = null
}

// Monitoring via Log Analytics
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for OMS agent"
  type        = string
}
variable "log_analytics_workspace_enabled" {
  description = "Whether to enable Log Analytics"
  type        = bool
  default     = true
}
variable "oms_agent_enabled" {
  description = "Whether to enable the OMS agent"
  type        = bool
  default     = true
}
variable "msi_auth_for_monitoring_enabled" {
  description = "Enable MSI for monitoring auth"
  type        = bool
  default     = true
}

// --- Ingress & cert-manager Variables ---

// cert-manager settings
variable "cert_manager_namespace" {
  description = "Namespace in which cert-manager is installed"
  type        = string
  default     = "cert-manager"
}
variable "cert_manager_release_name" {
  description = "Helm release name for cert-manager"
  type        = string
  default     = "cert-manager"
}
variable "cert_manager_chart_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.12.0"
}

// ACME / Let's Encrypt ClusterIssuer settings
variable "cluster_issuer_name" {
  description = "Name of the cert-manager ClusterIssuer"
  type        = string
  default     = "letsencrypt-prod"
}
variable "acme_server" {
  description = "ACME server URL for cert-manager"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}
variable "acme_email" {
  description = "Email address for ACME registration and recovery"
  type        = string
}
variable "cluster_issuer_secret_name" {
  description = "Name of the secret to hold the ACME private key"
  type        = string
  default     = "letsencrypt-prod-key"
}
variable "ingress_class" {
  description = "Ingress class annotation for HTTP-01 solver and Ingress"
  type        = string
  default     = "nginx"
}

// Application-specific Ingress settings
variable "ingress_name" {
  description = "Name of the Kubernetes Ingress resource"
  type        = string
}
variable "ingress_hosts" {
  description = "List of hostnames for the Ingress TLS and rules"
  type        = list(string)
}
variable "tls_secret_name" {
  description = "Name of the Kubernetes TLS secret for Ingress"
  type        = string
}
variable "service_name" {
  description = "Name of the backend Kubernetes Service"
  type        = string
}
variable "service_port" {
  description = "Port number of the backend Service"
  type        = number
  default     = 80
}
