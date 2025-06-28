resource "azurerm_subnet" "aks" {
  count                = length(var.subnets)
  name                 = "subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefix       = var.subnets[count.index]
}
