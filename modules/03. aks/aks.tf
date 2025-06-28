resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                  = "system"
    node_count            = var.agent_count
    vm_size               = var.agent_vm_size
    vnet_subnet_id        = var.node_subnet_id # Should be private subnet for security
    availability_zones    = var.availability_zones
    os_disk_size_gb       = 30
    enable_node_public_ip = false
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  tags = {
    environment = var.name
    owner       = "guillermolam"
    location    = var.location
  }
}
