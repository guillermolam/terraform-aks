variables {
  location            = "switzerlandnorth"
  resource_group_name = "test-rg"
  cluster_name        = "test-arc-cluster"
  kubernetes_version  = "1.24.6"
  kube_config         = "test-kube-config"
  kube_config_context = "test-context"
  agent_public_key_certificate = "test-cert"
}

provider "azurerm" {
  features {}
}

run "setup" {
  # Setup resources or mocks if needed before the test execution.
  module {
    source = "./testing/setup"
  }
}

run "execute" {
  # Execute the Arc AKS module configuration under test.
  module {
    source = "../../modules/04. arc_aks"
    location            = var.location
    resource_group_name = var.resource_group_name
    cluster_name        = var.cluster_name
    kubernetes_version  = var.kubernetes_version
    kube_config         = var.kube_config
    kube_config_context = var.kube_config_context
    agent_public_key_certificate = var.agent_public_key_certificate
  }
}

run "verify" {
  # Verify the Arc AKS cluster configuration.
  assert {
    condition     = azurerm_arc_kubernetes_cluster.arc.name == var.cluster_name
    error_message = "Arc cluster name does not match the expected value."
  }

  assert {
    condition     = azurerm_arc_kubernetes_provisioned_cluster.arcprov.kubernetes_version == var.kubernetes_version
    error_message = "Arc provisioned cluster Kubernetes version does not match the expected value."
  }

  assert {
    condition     = azurerm_arc_kubernetes_cluster_extension.monitoring.extension_type == "AzureMonitorContainers"
    error_message = "Monitoring extension type is incorrect."
  }
}
