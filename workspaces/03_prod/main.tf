terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateprod"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "../../modules/resource_group"

  name     = "aks-prod-rg"
  location = "switzerlandnorth"
  tags = {
    Environment = "Production"
    Managed_By  = "Terraform"
  }
}

module "aks_cluster" {
  source = "../../modules/aks"

  depends_on = [module.resource_group]

  cluster_name        = "prod-aks"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  kubernetes_version  = "1.25.5"
  node_count          = 3
  vm_size             = "Standard_D2s_v3"

  tags = {
    Environment = "Production"
    Managed_By  = "Terraform"
  }
}
