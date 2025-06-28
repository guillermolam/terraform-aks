resource "azurerm_subnet" "aks" {
  count                = length(var.subnets)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.subnets[count.index]]

  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault"
  ]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  # Enable network policies for enhanced security
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}
