// modules/vpn/vpn_module.tf
// Production-ready VPN Gateway module with optional BGP and IPSec

// variables.tf (inline)
variable "location" {
  description = "Azure region for VPN resources"
  type        = string
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
variable "gateway_subnet_id" {
  description = "ID of the GatewaySubnet for the VNet"
  type        = string
}
variable "gateway_sku" {
  description = "VPN Gateway SKU (e.g. VpnGw1, VpnGw2)"
  type        = string
  default     = "VpnGw1"
}
variable "vpn_type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}
variable "enable_bgp" {
  description = "Enable BGP on the VPN Gateway"
  type        = bool
  default     = false
}
variable "bgp_settings" {
  description = "BGP peer configuration when enable_bgp=true"
  type = object({
    asn                 = number
    peer_weight         = number
    bgp_peering_address = string
  })
  default = null
}
variable "connection_configs" {
  description = "List of site-to-site VPN connections"
  type = list(object({
    name                               = string
    local_network_gateway_id           = string
    shared_key                         = string
    enable_bgp                         = optional(bool, false)
    use_policy_based_traffic_selectors = optional(bool, false)
    ipsec_policy = optional(object({
      sa_lifetime_sec  = number
      sa_data_size_kb  = number
      ipsec_encryption = string
      ipsec_integrity  = string
      ike_encryption   = string
      ike_integrity    = string
      dh_group         = string
      pfs_group        = string
    }), null)
  }))
  default = []
}
variable "route_server_bgp_connection" {
  description = "Configuration for Route Server BGP connection (optional)"
  type = object({
    enabled         = bool
    route_server_id = string
    peer_asn        = number
    peer_ip         = string
  })
  default = {
    enabled         = false
    route_server_id = ""
    peer_asn        = 0
    peer_ip         = ""
  }
}
variable "tags" {
  description = "Tags to apply to all VPN resources"
  type        = map(string)
  default     = {}
}
