# Install cert-manager
# Note: The Helm provider should be configured at the root or workspace level, not within this module.
# Ensure the Helm provider is set up in the calling configuration with the appropriate kubeconfig.

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

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
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
  version    = "4.11.3"

  create_namespace = false
  depends_on       = [kubernetes_namespace.ingress_nginx]

  values = [
    yamlencode({
      controller = {
        publishService = {
          enabled = true
        }
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/azure-load-balancer-enable-tcp-reset" = "true"
          }
        }
      }
    })
  ]

}

# ClusterIssuer for Let's Encrypt
# Temporarily commented out due to manifest parsing issues with yamlencode
/*
resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  manifest = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cluster_issuer_name
    }
    spec = {
      acme = {
        server = var.acme_server
        email  = var.acme_email
        privateKeySecretRef = {
          name = var.cluster_issuer_secret_name
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = var.ingress_class
              }
            }
          }
        ]
      }
    }
  })
}
*/

# Ingress with TLS and automated cert rotation
# Temporarily commented out due to manifest parsing issues with yamlencode
/*
resource "kubernetes_manifest" "app_ingress" {
  manifest = yamlencode({
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name        = var.ingress_name
      namespace   = var.ingress_namespace
      annotations = {
        "kubernetes.io/ingress.class" = var.ingress_class
        "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
      }
    }
    spec = {
      tls = [
        {
          hosts       = var.ingress_hosts
          secretName  = var.tls_secret_name
        }
      ]
      rules = [
        for h in var.ingress_hosts : {
          host = h
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend  = {
                  service = {
                    name = var.service_name
                    port = {
                      number = var.service_port
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
  depends_on = [helm_release.cert_manager, helm_release.nginx_ingress]
}
*/
