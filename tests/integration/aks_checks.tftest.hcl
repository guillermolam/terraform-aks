check "rbac_enabled" {
  assert {
    condition     = azurerm_kubernetes_cluster.aks.role_based_access_control[0].enabled == true
    error_message = "AKS cluster MUST have RBAC enabled."
  }
}

check "no_public_node_ips" {
  assert {
    condition     = azurerm_kubernetes_cluster.aks.default_node_pool[0].enable_node_public_ip == false
    error_message = "Node pools must NOT have public IPs enabled."
  }
}

check "correct_azs" {
  assert {
    condition     = length(azurerm_kubernetes_cluster.aks.default_node_pool[0].availability_zones) >= 2
    error_message = "Cluster should be distributed across at least 2 Availability Zones."
  }
}

check "uses_private_subnet" {
  assert {
    condition     = can(regex("private", azurerm_kubernetes_cluster.aks.default_node_pool[0].vnet_subnet_id))
    error_message = "Default node pool must use a subnet named 'private'."
  }
}
