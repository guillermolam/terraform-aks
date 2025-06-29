# Install cert-manager
provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
  helm_driver = "kubeconfig"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = var.cert_manager_release_name
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version

  create_namespace = false
  depends_on       = [kubernetes_namespace.cert_manager]

  set = {
    name  = "installCRDs"
    value = "true"
  }
}

# Install NGINX Ingress Controller
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = var.ingress_namespace
  }
}

resource "helm_release" "nginx_ingress" {
  name       = var.ingress_release_name
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_chart_version

  create_namespace = false
  depends_on       = [kubernetes_namespace.ingress_nginx]

  set = {
    name  = "controller.scope.enabled"
    value = "true"
  }

  set = {
    name  = "controller.scope.namespace"
    value = var.ingress_namespace
  }
  set = {
    name  = "controller.admissionWebhooks.enabled"
    value = "true"
  }

}

# ClusterIssuer for Let's Encrypt
# Terraform interpolates HCL expressions inside heredoc manifests automatically at plan/apply time
resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  count = var.kube_config != "" ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "user@example.com"
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

# Ingress with TLS and automated cert rotation
# Terraform interpolates HCL expressions inside heredoc manifests automatically at plan/apply time
resource "kubernetes_manifest" "app_ingress" {
  count = var.kube_config != "" ? 1 : 0
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "app-ingress"
      namespace = "ingress-nginx"
      annotations = {
        "kubernetes.io/ingress.class"    = "nginx"
        "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      }
    }
    spec = {
      tls = [
        {
          hosts      = ["example.com"]
          secretName = "app-tls"
        }
      ]
      rules = [
        {
          host = "example.com"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "app-service"
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
  depends_on = [helm_release.cert_manager, helm_release.nginx_ingress]
}
