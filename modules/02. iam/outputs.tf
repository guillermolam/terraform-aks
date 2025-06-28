output "principal_id" {
  description = "The Service Principal (app) object ID used for role assignments"
  value       = var.client_id
}

output "role_assignment_ids" {
  description = "List of role assignment IDs created for the SP"
  value       = azurerm_role_assignment.aks_sp[*].id
}
