// outputs.tf for VPN Gateway module

output "vpn_gateway_public_ip_id" {
  description = "ID of the Public IP allocated for the VPN Gateway"
  value       = azurerm_public_ip.vpn_gateway_ip.id
}

output "vpn_gateway_id" {
  description = "ID of the Virtual Network Gateway (VPN)"
  value       = azurerm_virtual_network_gateway.this.id
}

output "vpn_connection_ids" {
  description = "Map of VPN connection names to their IDs"
  value = {
    for name, conn in azurerm_virtual_network_gateway_connection.connections :
    name => conn.id
  }
}

output "vpn_connection_shared_keys" {
  description = "Map of VPN connection names to their shared keys"
  value = {
    for name, conn in azurerm_virtual_network_gateway_connection.connections :
    name => conn.shared_key
  }
}
