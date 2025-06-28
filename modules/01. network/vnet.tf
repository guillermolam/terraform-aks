resource "azurerm_virtual_network" "aks" {
  name                = "${var.name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}
