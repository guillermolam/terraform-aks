resource "azurerm_network_security_group" "aks" {
  name                = "${var.name}-nsg"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_network_security_rule" "aks_allow_internet_out" {
  name                        = "AllowOutboundInternet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  network_security_group_name = azurerm_network_security_group.aks.name
  resource_group_name         = azurerm_resource_group.aks.name
}
