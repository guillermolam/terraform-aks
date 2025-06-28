variables {
  location            = "switzerlandnorth"
  resource_group_name = "test-rg"
  gateway_subnet_id   = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/GatewaySubnet"
  gateway_sku         = "VpnGw1"
  vpn_type            = "RouteBased"
  enable_bgp          = true
  bgp_settings        = {
    asn               = 65515
    peer_weight       = 0
    bgp_peering_address = "10.0.0.1"
  }
  connection_configs  = [
    {
      name                       = "test-connection"
      local_network_gateway_id   = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/localNetworkGateways/test-lng"
      shared_key                 = "test-shared-key"
      enable_bgp                 = true
      use_policy_based_traffic_selectors = false
      ipsec_policy               = {
        sa_lifetime_sec       = 3600
        sa_data_size_kb       = 102400
        ipsec_encryption      = "AES256"
        ipsec_integrity       = "SHA256"
        ike_encryption        = "AES256"
        ike_integrity         = "SHA256"
        dh_group              = "DHGroup14"
        pfs_group             = "PFS2048"
      }
    }
  ]
  route_server_bgp_connection = {
    enabled            = true
    route_server_id    = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualHubs/test-hub/routeServers/test-rs"
    peer_asn           = 65514
    peer_ip            = "10.0.0.2"
  }
  tags                = {
    environment = "test"
  }
}

provider "azurerm" {
  features {}
}

run "setup" {
  # Setup resources or mocks if needed before the test execution.
  module {
    source = "./testing/setup"
  }
}

run "execute" {
  # Execute the VPN module configuration under test.
  module {
    source = "../../modules/05. Vpn"
    location            = var.location
    resource_group_name = var.resource_group_name
    gateway_subnet_id   = var.gateway_subnet_id
    gateway_sku         = var.gateway_sku
    vpn_type            = var.vpn_type
    enable_bgp          = var.enable_bgp
    bgp_settings        = var.bgp_settings
    connection_configs  = var.connection_configs
    route_server_bgp_connection = var.route_server_bgp_connection
    tags                = var.tags
  }
}

run "verify" {
  # Verify the VPN Gateway configuration.
  assert {
    condition     = azurerm_virtual_network_gateway.this.name == "${var.resource_group_name}-vpn-gateway"
    error_message = "VPN Gateway name does not match the expected value."
  }

  assert {
    condition     = azurerm_virtual_network_gateway.this.enable_bgp == var.enable_bgp
    error_message = "BGP enablement does not match the expected value."
  }

  assert {
    condition     = length(azurerm_virtual_network_gateway_connection.connections) == length(var.connection_configs)
    error_message = "Number of VPN connections does not match the expected count."
  }

  assert {
    condition     = var.route_server_bgp_connection.enabled ? length(azurerm_route_server_bgp_connection.route_server_bgp) == 1 : length(azurerm_route_server_bgp_connection.route_server_bgp) == 0
    error_message = "Route Server BGP connection creation does not match the expected condition."
  }
}
