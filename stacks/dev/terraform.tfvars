location                = "switzerlandnorth"
environment            = "dev"
resource_group_name    = "aks-dev-rg"
kubernetes_version     = "1.25.5"
system_node_count      = 3
node_resource_group    = "aks-dev-node-rg"

default_node_pool = {
  name                = "systempool"
  node_count          = 3
  vm_size             = "Standard_D2s_v3"
  type                = "VirtualMachineScaleSets"
  availability_zones  = ["1", "2", "3"]
  enable_auto_scaling = true
  min_count          = 2
  max_count          = 5
}

acr_name              = "devacr"
acr_sku               = ""

tags = {
  Environment = "Dev"
  ManagedBy   = "Terraform"
  Team        = "DevOps"
}

network = {
  vnet_name          = "aks-dev-vnet"
  address_space      = ["10.0.0.0/16"]
  subnet_name        = "aks-dev-subnet"
  subnet_prefixes    = ["10.0.1.0/24"]
}

monitoring = {
  log_analytics_workspace_name = "aks-dev-logs"
  retention_in_days           = 30
}
