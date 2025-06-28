variables {
  environment = "dev"
  location = "switzerlandnorth"
  resource_group_name = "rg-aks-dev"
}

run "verify_network_configuration" {
  command = plan

  assert {
    condition = module.network.vnet_address_space[0] == "10.0.0.0/16"
    error_message = "VNet address space must be 10.0.0.0/16 for dev environment"
  }

  assert {
    condition = module.network.subnet_address_prefixes["aks"] == "10.0.1.0/24"
    error_message = "AKS subnet address prefix must be 10.0.1.0/24"
  }

  assert {
    condition = module.network.nsg_rules["allow_api_server"].destination_port_range == "443"
    error_message = "NSG must allow HTTPS traffic to API server"
  }
}

run "verify_aks_cluster_configuration" {
  command = plan

  assert {
    condition = module.aks.kubernetes_version >= "1.26.0"
    error_message = "AKS version must be at least 1.26.0"
  }

  assert {
    condition = module.aks.node_pool_vm_size == "Standard_D2s_v3"
    error_message = "Node pool VM size must be Standard_D2s_v3 for dev environment"
  }

  assert {
    condition = module.aks.node_count >= 2 && module.aks.node_count <= 3
    error_message = "Node count must be between 2 and 3 for dev environment"
  }

  assert {
    condition = module.aks.network_plugin == "azure"
    error_message = "Network plugin must be set to azure"
  }

  assert {
    condition = module.aks.network_policy == "azure"
    error_message = "Network policy must be set to azure"
  }
}

run "verify_security_configuration" {
  command = plan

  assert {
    condition = module.aks.enable_rbac == true
    error_message = "RBAC must be enabled"
  }

  assert {
    condition = module.aks.private_cluster_enabled == false
    error_message = "Dev cluster should not be private"
  }

  assert {
    condition = module.aks.availability_zones == [1, 2, 3]
    error_message = "AKS cluster must be deployed across all availability zones"
  }
}
