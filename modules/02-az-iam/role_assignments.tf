resource "azurerm_role_assignment" "aks_sp" {
  scope                = var.resource_group_id
  role_definition_name = var.role_definition_name
  principal_id         = var.client_id
  principal_type       = var.principal_type
}
