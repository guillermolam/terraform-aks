output "resource_group_id" {
  description = "The ID of the resource group (if created in this module)"
  value       = azurerm_resource_group.this.id
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "subnets" {
  description = "List of all subnet objects"
  value       = azurerm_subnet.this
}

output "nsg_ids" {
  description = "Map of network security group IDs by subnet name"
  value       = azurerm_network_security_group.nsg
}
