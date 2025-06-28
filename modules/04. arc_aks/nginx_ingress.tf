# Install cert-manager
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
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

  set {
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

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-enable-tcp-reset"
    value = "true"
  }
}

# ClusterIssuer for Let's Encrypt
# Terraform interpolates HCL expressions inside heredoc manifests automatically at plan/apply time
resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  manifest = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.cluster_issuer_name}
spec:
  acme:
    server: ${var.acme_server}
    email: ${var.acme_email}
    privateKeySecretRef:
      name: ${var.cluster_issuer_secret_name}
    solvers:
    - http01:
        ingress:
          class: ${var.ingress_class}
YAML
}

# Ingress with TLS and automated cert rotation
# Terraform interpolates HCL expressions inside heredoc manifests automatically at plan/apply time
resource "kubernetes_manifest" "app_ingress" {
  manifest = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${var.ingress_name}
  namespace: ${var.ingress_namespace}
  annotations:
    kubernetes.io/ingress.class: "${var.ingress_class}"
    cert-manager.io/cluster-issuer: "${var.cluster_issuer_name}"
spec:
  tls:
  - hosts:
${join("\n", [for h in var.ingress_hosts : "    - ${h}"])}
    secretName: ${var.tls_secret_name}
  rules:
${join("\n", [for h in var.ingress_hosts : <<-RULE
  - host: ${h}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${var.service_name}
            port:
              number: ${var.service_port}
RULE
])}
YAML
  depends_on = [helm_release.cert_manager, helm_release.nginx_ingress]
}
