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

variable "subnet_prefix" {
  description = "Prefixes for subnets in the virtual network."
  type        = list(string)
  default     = ["public-subnet-1", "public-subnet-2", "private-subnet-1", "private-subnet-2"]
}

variable "subnets" {
  description = <<-EOT
    List of CIDR blocks for subnets in the virtual network.
    Expect 4 entries: 2 public and 2 private subnets across 2 AZs.
  EOT
  type    = list(string)
}

variable "dns_servers" {
  description = "List of DNS server IP addresses for the virtual network. If not provided, no DNS servers will be set."
  type        = list(string)
  default     = []
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan"
  type        = string
  default     = ""
}

variable "enable_ddos_protection" {
  description = "Enable or disable DDoS protection"
  type        = bool
  default     = false
}

variable "bgp_peering_configs" {
  description = "Configurations for BGP peering"
  type        = list(object({
    asn          = number
    peering_name = string
    peer_ip      = string
    peer_asn     = number
  }))
  default     = []
}

variable "subnet_configs" {
  description = "Configurations for subnets in the virtual network"
  type        = list(object({
    name                        = string
    prefix                      = string
    service_endpoints           = optional(list(string), [])
    service_endpoint_policy_ids = optional(list(string), [])
    default_outbound_access     = optional(bool, true)
    delegations                 = optional(list(object({
      name               = string
      service_delegations = list(object({
        name    = string
        actions = list(string)
      }))
    })), [])
    nsg_id                      = optional(string)
  }))
}
