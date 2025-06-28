terraform {
  required_version = ">= 1.12.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.34.0"
    }
  }
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

  type          = "Vpn"
  vpn_type      = var.vpn_type
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
      asn         = bgp_settings.value.asn // Azure BGP ASN ([registry.terraform.io](https://registry.terraform.io/providers/hashicorp/azurerm/1.43.0/docs/resources/virtual_network_gateway?utm_source=chatgpt.com))
      peer_weight = bgp_settings.value.peer_weight
    }
  }

  tags = var.tags
}

// VPN Connections
resource "azurerm_virtual_network_gateway_connection" "connections" {
  for_each                           = { for c in var.connection_configs : c.name => c }
  name                               = each.value.name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id           = each.value.local_network_gateway_id
  shared_key                         = each.value.shared_key
  type                               = "IPsec"
  use_policy_based_traffic_selectors = each.value.use_policy_based_traffic_selectors
  enable_bgp                         = each.value.enable_bgp

  dynamic "ipsec_policy" {
    for_each = each.value.ipsec_policy != null ? [each.value.ipsec_policy] : []
    content {
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      dh_group         = ipsec_policy.value.dh_group
      pfs_group        = ipsec_policy.value.pfs_group
    }
  }

  tags = var.tags
}

// Optional Route Server BGP Connection
resource "azurerm_route_server_bgp_connection" "route_server_bgp" {
  count           = var.route_server_bgp_connection.enabled ? 1 : 0
  name            = "${var.resource_group_name}-route-server-bgp"
  route_server_id = var.route_server_bgp_connection.route_server_id
  peer_asn        = var.route_server_bgp_connection.peer_asn
  peer_ip         = var.route_server_bgp_connection.peer_ip

  depends_on = [azurerm_virtual_network_gateway.this]
}
