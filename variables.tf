variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "client_id" {
  type        = string
  description = "Azure Client ID for Service Principal"
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret for Service Principal"
  sensitive   = true
}
