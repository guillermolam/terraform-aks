variable "client_id" {
  description = "The Application (client) ID of the Service Principal for AKS."
  type        = string
}

variable "resource_group_id" {
  description = "The ID of the resource group to which roles will be assigned."
  type        = string
}

variable "role_definition_name" {
  description = "The Azure role definition to assign to the Service Principal (e.g., 'Contributor')."
  type        = string
  default     = "Contributor"
}

variable "principal_type" {
  description = "The type of principal to assign (default: ServicePrincipal)."
  type        = string
  default     = "ServicePrincipal"
}
