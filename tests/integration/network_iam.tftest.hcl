variables {
  location            = "switzerlandnorth"
  resource_group_name = "test-rg"
  vnet_name           = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_configs      = [
    {
      name   = "public-subnet-1"
      prefix = "10.0.1.0/24"
    },
    {
      name   = "private-subnet-1"
      prefix = "10.0.2.0/24"
    }
  ]
  client_id           = "test-client-id"
  role_definition_name = "Contributor"
  principal_type      = "ServicePrincipal"
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

run "execute_network" {
  # Execute the Network module configuration under test.
  module {
    source = "../../modules/01. network"
    location            = var.location
    resource_group_name = var.resource_group_name
    vnet_name           = var.vnet_name
    address_space       = var.address_space
    subnet_configs      = var.subnet_configs
  }
}

run "execute_iam" {
  # Execute the IAM module configuration under test.
  module {
    source = "../../modules/02. iam"
    resource_group_id    = "/subscriptions/test-sub/resourceGroups/test-rg"
    role_definition_name = var.role_definition_name
    client_id            = var.client_id
    principal_type       = var.principal_type
  }
}

run "verify_network" {
  # Verify the Network configuration.
  assert {
    condition     = azurerm_virtual_network.this.name == var.vnet_name
    error_message = "Virtual Network name does not match the expected value."
  }

  assert {
    condition     = length(azurerm_subnet.this) == length(var.subnet_configs)
    error_message = "Number of subnets created does not match the expected count."
  }
}

run "verify_iam" {
  # Verify the IAM configuration.
  assert {
    condition     = azurerm_role_assignment.aks_sp.role_definition_name == var.role_definition_name
    error_message = "Role definition name does not match the expected value."
  }

  assert {
    condition     = azurerm_role_assignment.aks_sp.principal_type == var.principal_type
    error_message = "Principal type does not match the expected value."
  }
}
