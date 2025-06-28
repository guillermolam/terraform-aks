variables {
  environment = "prod"
  location    = "westeurope"
}

run "verify_prod_environment" {
  command = plan

  assert {
    condition     = var.environment == "prod"
    error_message = "Environment must be set to 'prod' for production stack"
  }

  assert {
    condition     = var.location == "westeurope"
    error_message = "Location must be set to 'westeurope' for production environment"
  }
}

run "verify_resource_naming" {
  command = plan

  assert {
    condition     = length(regexall("^prod-", module.aks.cluster_name)) > 0
    error_message = "AKS cluster name must start with 'prod-' prefix"
  }
}

run "verify_prod_configuration" {
  command = plan

  assert {
    condition     = module.aks.node_count >= 3
    error_message = "Production environment requires minimum 3 nodes"
  }

  assert {
    condition     = module.aks.enable_auto_scaling == true
    error_message = "Auto-scaling must be enabled in production"
  }

  assert {
    condition     = module.aks.kubernetes_version != ""
    error_message = "Kubernetes version must be specified"
  }
}
