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
    asn               = number
    peer_weight       = number
    bgp_peering_address = string
  })
  default = null
}
variable "connection_configs" {
  description = "List of site-to-site VPN connections"
  type = list(object({
    name                       = string
    local_network_gateway_id   = string
    shared_key                 = string
    enable_bgp                 = optional(bool, false)
    use_policy_based_traffic_selectors = optional(bool, false)
    ipsec_policy               = optional(object({
      sa_lifetime_sec       = number
      sa_data_size_kb       = number
      ipsec_encryption      = string
      ipsec_integrity       = string
      ike_encryption        = string
      ike_integrity         = string
      dh_group              = string
      pfs_group             = string
    }), null)
  }))
  default = []
}
variable "tags" {
  description = "Tags to apply to all VPN resources"
  type        = map(string)
  default     = {}
}

// Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_ip" {
  name                = "${var.resource_group_name}-vpn-gateway-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
  tags                = var.tags
}

// VPN Gateway
resource "azurerm_virtual_network_gateway" "this" {
  name                = "${var.resource_group_name}-vpn-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = var.vpn_type
  active_active = false
  sku           = var.gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  enable_bgp = var.enable_bgp

  dynamic "bgp_settings" {
    for_each = var.enable_bgp && var.bgp_settings != null ? [var.bgp_settings] : []
    content {
      asn               = bgp_settings.value.asn      // Azure BGP ASN ([registry.terraform.io](https://registry.terraform.io/providers/hashicorp/azurerm/1.43.0/docs/resources/virtual_network_gateway?utm_source=chatgpt.com))
      peer_weight       = bgp_settings.value.peer_weight
      bgp_peering_address = bgp_settings.value.bgp_peering_address
    }
  }

  tags = var.tags
}

// VPN Connections
resource "azurerm_virtual_network_gateway_connection" "connections" {
  for_each                  = { for c in var.connection_configs : c.name => c }
  name                      = each.value.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id  = each.value.local_network_gateway_id
  shared_key                = each.value.shared_key
  type                      = "IPsec"
  use_policy_based_traffic_selectors = each.value.use_policy_based_traffic_selectors
  enable_bgp                = each.value.enable_bgp

  dynamic "ipsec_policy" {
    for_each = each.value.ipsec_policy != null ? [each.value.ipsec_policy] : []
    content {
      sa_lifetime_sec   = ipsec_policy.value.sa_lifetime_sec
      sa_data_size_kb   = ipsec_policy.value.sa_data_size_kb
      ipsec_encryption  = ipsec_policy.value.ipsec_encryption
      ipsec_integrity   = ipsec_policy.value.ipsec_integrity
      ike_encryption    = ipsec_policy.value.ike_encryption
      ike_integrity     = ipsec_policy.value.ike_integrity
      dh_group          = ipsec_policy.value.dh_group
      pfs_group         = ipsec_policy.value.pfs_group
    }
  }

  tags = var.tags
}
