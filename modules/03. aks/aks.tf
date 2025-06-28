resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Identity & Security
  private_cluster_enabled             = true
  workload_identity_enabled           = true
  oidc_issuer_enabled                 = true
  azure_policy_enabled                = true
  role_based_access_control_enabled   = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    tenant_id              = module.iam.tenant_id
    admin_group_object_ids = module.iam.admin_group_object_ids
    managed                = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.iam.control_plane_uami_id]
  }

  # Networking (Overlay + dual-stack)
  network_profile {
    network_plugin        = "azure"
    network_plugin_mode   = "overlay"
    ip_versions           = ["IPv4","IPv6"]
    pod_cidrs             = module.network.pod_cidrs
    service_cidrs         = module.network.service_cidrs
    dns_service_ip        = module.network.dns_service_ip
    load_balancer_sku     = "Standard"
    outbound_type         = "managedNATGateway"
    network_policy        = "calico"
    ebpf_data_plane       = "cilium"

    nat_gateway_profile {
      idle_timeout_in_minutes   = module.network.nat_gateway_profile.idle_timeout_in_minutes
      managed_outbound_ip_count = module.network.nat_gateway_profile.managed_outbound_ip_count
    }
  }

  # Default Node Pool (with fixed autoscale limits and pod caps)
  default_node_pool {
    name                = "agentpool"
    vm_size             = module.compute.default_vm_size
    enable_auto_scaling = true
    min_count           = module.compute.default_min_count
    max_count           = module.compute.default_max_count

    node_count          = module.compute.default_min_count
    max_pods            = module.compute.default_max_pods

    os_disk_size_gb     = var.agent_os_disk_size_gb
    vnet_subnet_id      = module.network.agent_subnet_id
    node_labels         = var.agent_labels
  }

  auto_scaler_profile {
    balance_similar_node_groups      = var.auto_scaler_profile_balance_similar_node_groups
    empty_bulk_delete_max            = var.auto_scaler_profile_empty_bulk_delete_max
    expander                         = var.auto_scaler_profile_expander
    max_graceful_termination_sec     = var.auto_scaler_profile_max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile_max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile_max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile_max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile_new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile_scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile_scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile_scale_down_delay_after_failure
    scale_down_unneeded              = var.auto_scaler_profile_scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile_scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile_scale_down_utilization_threshold
    scan_interval                    = var.auto_scaler_profile_scan_interval
    skip_nodes_with_local_storage    = var.auto_scaler_profile_skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.auto_scaler_profile_skip_nodes_with_system_pods
  }

  # KEDA/VPA autoscaler profile
  workload_autoscaler_profile {
    keda_enabled                    = true
    vertical_pod_autoscaler_enabled = true
  }

  # Monitoring via Log Analytics
  oms_agent {
    log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  tags = module.common.tags
  depends_on = [
    module.network,
    module.compute,
    module.monitoring,
    module.iam
  ]
}
