variables {
  environment = "prod"
  location = "switzerlandnorth"
  resource_group_name = "rg-aks-prod"
}

run "verify_network_configuration" {
  command = plan

  assert {
    condition = module.network.vnet_address_space[0] == "10.0.0.0/16"
    error_message = "VNet address space must be 10.0.0.0/16 for prod environment"
  }

  assert {
    condition = module.network.subnet_address_prefixes["aks"] == "10.0.1.0/24"
    error_message = "AKS subnet address prefix must be 10.0.1.0/24"
  }

  assert {
    condition = module.network.nsg_rules["allow_api_server"].destination_port_range == "443"
    error_message = "NSG must allow HTTPS traffic to API server"
  }

  assert {
    condition = module.network.enable_ddos_protection == true
    error_message = "DDoS protection must be enabled for prod environment (Well-Architected Framework - Security)"
  }

  assert {
    condition = length(module.network.bgp_peering_configs) > 0
    error_message = "BGP peering must be configured for advanced networking in prod (Operator Best Practices - Network)"
  }
}

run "verify_aks_cluster_configuration" {
  command = plan

  assert {
    condition = module.aks.kubernetes_version >= "1.27.0"
    error_message = "AKS version must be at least 1.27.0 for prod environment"
  }

  assert {
    condition = module.aks.node_pool_vm_size == "Standard_D4s_v3" || module.aks.node_pool_vm_size == "Standard_D8s_v3"
    error_message = "Node pool VM size must be Standard_D4s_v3 or Standard_D8s_v3 for prod environment performance"
  }

  assert {
    condition = module.aks.node_count >= 3 && module.aks.node_count <= 10
    error_message = "Node count must be between 3 and 10 for prod environment high availability"
  }

  assert {
    condition = module.aks.network_plugin == "azure"
    error_message = "Network plugin must be set to azure for prod (Azure CNI Overlay)"
  }

  assert {
    condition = module.aks.network_policy == "azure"
    error_message = "Network policy must be set to azure for prod (Azure CNI Overlay)"
  }

  assert {
    condition = module.aks.outbound_type == "userDefinedRouting"
    error_message = "Outbound type must be userDefinedRouting for prod environment (Operator Best Practices - Network)"
  }
}

run "verify_security_configuration" {
  command = plan

  assert {
    condition = module.aks.enable_rbac == true
    error_message = "RBAC must be enabled for prod environment (Zero Trust Architecture)"
  }

  assert {
    condition = module.aks.private_cluster_enabled == true
    error_message = "Prod cluster must be private for security (Zero Trust Architecture, NIS2, GDPR)"
  }

  assert {
    condition = module.aks.availability_zones == [1, 2, 3]
    error_message = "AKS cluster must be deployed across all availability zones for high availability (Well-Architected Framework - Reliability)"
  }

  assert {
    condition = module.aks.msi_auth_for_monitoring_enabled == true
    error_message = "Managed Service Identity (MSI) must be enabled for monitoring in prod (Zero Trust Architecture)"
  }
}

run "verify_acr_access" {
  command = plan

  assert {
    condition = module.aks.acr_access_enabled == true
    error_message = "AKS must have access to Azure Container Registry (ACR) for prod environment"
  }
}

run "verify_nginx_ingress" {
  command = plan

  assert {
    condition = module.aks.ingress_enabled == true
    error_message = "AKS must have NGINX Ingress Controller configured for prod environment"
  }
}

run "verify_cert_rotation" {
  command = plan

  assert {
    condition = module.aks.cert_manager_enabled == true
    error_message = "AKS must have cert-manager for automated certificate rotation in prod (Cyber Resilience Act)"
  }
}

run "verify_cilium_configuration" {
  command = plan

  assert {
    condition = module.aks.cilium_enabled == true
    error_message = "AKS must have Cilium configured for advanced network policy in prod (Operator Best Practices - Network)"
  }
}

run "verify_opentelemetry" {
  command = plan

  assert {
    condition = module.aks.opentelemetry_enabled == true
    error_message = "AKS must have OpenTelemetry configured for observability in prod (Well-Architected Framework - Operational Excellence)"
  }
}

run "verify_monitoring_and_logging" {
  command = plan

  assert {
    condition = module.aks.log_analytics_workspace_enabled == true
    error_message = "Log Analytics Workspace must be enabled for prod environment monitoring (Well-Architected Framework - Operational Excellence, DORA)"
  }

  assert {
    condition = module.aks.oms_agent_enabled == true
    error_message = "OMS Agent must be enabled for prod environment monitoring (NIST, ENISA)"
  }
}

run "verify_vpn_configuration" {
  command = plan

  assert {
    condition = module.vpn.vpn_enabled == true
    error_message = "VPN must be enabled for secure access in prod environment (VPN Best Practices, Zero Trust Architecture)"
  }

  assert {
    condition = module.vpn.vpn_type == "point-to-site"
    error_message = "VPN type must be point-to-site for prod environment (VPN Best Practices)"
  }
}

run "verify_compliance_standards" {
  command = plan

  assert {
    condition = module.aks.compliance_nis2_enabled == true
    error_message = "NIS2 compliance must be enabled for prod environment (NIS2)"
  }

  assert {
    condition = module.aks.compliance_gdpr_enabled == true
    error_message = "GDPR compliance must be enabled for prod environment (GDPR)"
  }

  assert {
    condition = module.aks.compliance_cra_enabled == true
    error_message = "Cyber Resilience Act (CRA) compliance must be enabled for prod environment (CRA)"
  }

  assert {
    condition = module.aks.compliance_dora_enabled == true
    error_message = "DORA compliance must be enabled for prod environment (DORA)"
  }

  assert {
    condition = module.aks.compliance_nist_enabled == true
    error_message = "NIST compliance must be enabled for prod environment (NIST)"
  }

  assert {
    condition = module.aks.compliance_enisa_enabled == true
    error_message = "ENISA compliance must be enabled for prod environment (ENISA)"
  }
}

run "verify_well_architected_framework" {
  command = plan

  assert {
    condition = module.aks.waf_cost_optimization == true
    error_message = "Well-Architected Framework Cost Optimization must be considered for prod environment"
  }

  assert {
    condition = module.aks.waf_operational_excellence == true
    error_message = "Well-Architected Framework Operational Excellence must be considered for prod environment"
  }

  assert {
    condition = module.aks.waf_performance_efficiency == true
    error_message = "Well-Architected Framework Performance Efficiency must be considered for prod environment"
  }

  assert {
    condition = module.aks.waf_reliability == true
    error_message = "Well-Architected Framework Reliability must be considered for prod environment"
  }

  assert {
    condition = module.aks.waf_security == true
    error_message = "Well-Architected Framework Security must be considered for prod environment"
  }
}
