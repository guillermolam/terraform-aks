variables {
  location            = "switzerlandnorth"
  resource_group_name = "test-rg"
  agent_vm_size       = "Standard_DS2_v2"
  agent_count         = 3
  vnet_subnet_id      = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-subnet-1"
}

provider "azurerm" {
  features {}
}

run "setup" {
  # Setup resources or mocks if needed before the test execution.
  module {
    source = "./testing/setup"
  }
}

run "execute" {
  # Execute the AKS module configuration under test.
  module {
    source = "../../modules/03. aks"
    location            = var.location
    resource_group_name = var.resource_group_name
    agent_vm_size       = var.agent_vm_size
    agent_count         = var.agent_count
    vnet_subnet_id      = var.vnet_subnet_id
  }
}

run "verify" {
  # Verify the AKS cluster configuration.
  assert {
    condition     = azurerm_kubernetes_cluster.aks.role_based_access_control[0].enabled == true
    error_message = "AKS cluster MUST have RBAC enabled."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.default_node_pool[0].enable_node_public_ip == false
    error_message = "Node pools must NOT have public IPs enabled."
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.aks.default_node_pool[0].availability_zones) >= 2
    error_message = "Cluster should be distributed across at least 2 Availability Zones."
  }

  assert {
    condition     = can(regex("private", azurerm_kubernetes_cluster.aks.default_node_pool[0].vnet_subnet_id))
    error_message = "Default node pool must use a subnet named 'private'."
  }
}
