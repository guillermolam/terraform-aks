# Configuration for on-premises Kubernetes cluster with Rancher Desktop
provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_config_context
  }
}

# Deploy necessary resources for on-premises Kubernetes
resource "kubernetes_namespace" "test_namespace" {
  metadata {
    name = "test-namespace"
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        publishService = {
          enabled = true
        }
        service = {
          type = "NodePort"
        }
      }
    })
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.12.0"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
}

output "namespace_created" {
  description = "Name of the created namespace"
  value       = kubernetes_namespace.test_namespace.metadata[0].name
}

output "nginx_ingress_status" {
  description = "Status of NGINX Ingress Controller deployment"
  value       = helm_release.nginx_ingress.status
}

output "cert_manager_status" {
  description = "Status of Cert-Manager deployment"
  value       = helm_release.cert_manager.status
}

module "ngrok" {
  source = "../../modules/06. ngrok"

  ngrok_api_key       = var.ngrok_api_key
  tls_certificate_pem = var.tls_certificate_pem
  tls_private_key_pem = var.tls_private_key_pem
}
