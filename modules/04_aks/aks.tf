# Azure Kubernetes Service (AKS) Cluster
# Production-ready managed Kubernetes cluster

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_group_name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.resource_group_name}-aks"

  default_node_pool {
    name            = "default"
    node_count      = var.agent_count
    vm_size         = var.agent_vm_size
    vnet_subnet_id  = var.vnet_subnet_id
    zones           = ["1", "2", "3"]
    min_count       = var.agent_count
    max_count       = var.agent_count + 2
    type            = "VirtualMachineScaleSets"
    max_pods        = 110
    os_disk_size_gb = 30
    os_disk_type    = "Managed"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "10.0.0.10"
    service_cidr      = "10.0.0.0/16"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to node count as it might be adjusted manually or by autoscaling
      default_node_pool[0].node_count,
    ]
  }
}
