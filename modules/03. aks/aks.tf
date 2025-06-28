resource "azurerm_kubernetes_cluster" "aks" {
  # ...
  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = var.agent_vm_size
    vnet_subnet_id = azurerm_subnet.aks[0].id
  }
  # ...
}
