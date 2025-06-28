resource "azurerm_subnet_network_security_group_association" "main" {
  count                     = length(azurerm_subnet.main)
  subnet_id                 = azurerm_subnet.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}
