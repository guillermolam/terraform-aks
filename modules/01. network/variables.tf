variable "client_id" {
  description = "Service Principal (app) client ID"
  type        = string
}

variable "client_secret" {
  description = "Service Principal client secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "switzerlandnorth"
}

variable "name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create/use"
  type        = string
}

variable "agent_vm_size" {
  description = "VM size for AKS agent pool"
  type        = string
}

variable "agent_count" {
  description = "Number of nodes in the AKS agent pool"
  type        = number
}

variable "subnets" {
  description = <<-EOT
    List of CIDR blocks for subnets in the virtual network.
    Expect 4 entries: 2 public and 2 private subnets across 2 AZs.
  EOT
  type    = list(string)
}
