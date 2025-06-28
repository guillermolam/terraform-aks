
variable "tags" {
  description = "Tags to apply to all network resources"
  type        = map(string)
  default     = {}
}


resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers = length(var.dns_servers) > 0 ? var.dns_servers : []

  // DDoS Protection configuration
  ddos_protection_plan {
    id     = var.ddos_protection_plan_id
    enable = var.enable_ddos_protection
  }

  encryption {
    enforcement = "AllowUnencrypted"
  }

  bgp_community = "Active"

  dynamic "bgp_peering" {
    for_each = var.bgp_peering_configs
    content {
      asn          = bgp_peering.value.asn
      peering_name = bgp_peering.value.peering_name
      peer_ip      = bgp_peering.value.peer_ip
      peer_asn     = bgp_peering.value.peer_asn
    }
  }

  subnet = {
    for_each = var.subnet_configs
    name                 = each.value.name
    address_prefixes     = [each.value.prefix]
  }

  private_endpoint_vnet_policies = "Basic"
  flow_timeout_in_minutes = "30"

  tags = var.tags
}
