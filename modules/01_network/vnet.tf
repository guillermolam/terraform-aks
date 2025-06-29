
variable "tags" {
  description = "Tags to apply to all network resources"
  type        = map(string)
  default     = {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}


resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : []

  // DDoS Protection configuration
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != "" ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = var.enable_ddos_protection
    }
  }

  encryption {
    enforcement = "AllowUnencrypted"
  }

  # Note: bgp_peering block and bgp_community are commented out as they are not supported or invalid in the current provider version.
  # bgp_community = "Active"

  # Note: bgp_peering block is commented out as it is not supported in the current provider version.
  # dynamic "bgp_peering" {
  #   for_each = var.bgp_peering_configs
  #   content {
  #     asn          = bgp_peering.value.asn
  #     peering_name = bgp_peering.value.peering_name
  #     peer_ip      = bgp_peering.value.peer_ip
  #     peer_asn     = bgp_peering.value.peer_asn
  #   }
  # }

  dynamic "subnet" {
    for_each = var.subnet_configs
    content {
      name                 = subnet.value.name
      address_prefixes     = [subnet.value.prefix]
    }
  }

  private_endpoint_vnet_policies = "Basic"
  flow_timeout_in_minutes        = "30"

  tags = var.tags
}
