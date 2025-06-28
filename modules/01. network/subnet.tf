resource "azurerm_subnet" "this" {
  for_each             = { for s in var.subnet_configs : s.name => s }
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]

  service_endpoints                      = lookup(each.value, "service_endpoints", [])
  service_endpoint_policy_ids            = lookup(each.value, "service_endpoint_policy_ids", [])
  default_outbound_access_enabled        = lookup(each.value, "default_outbound_access", true)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", [])
    content {
      name = delegation.value.name
      dynamic "service_delegation" {
        for_each = delegation.value.service_delegations
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each                  = azurerm_subnet.this
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
