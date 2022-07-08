# Traefik Deployment

resource "kubernetes_namespace" "traefik" {
  depends_on = [
    time_sleep.wait_for_kubernetes
  ]

  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  depends_on = [
    kubernetes_namespace.traefik
  ]

  name      = "traefik"
  namespace = "traefik"

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  # Set Traefik as the Default ingress controller
  set {
    name  = "ingressClass.enabled"
    value = "true"
  }
  set {
    name  = "ingressClass.isDefaultClass"
    value = "true"
  }

  # Default redirect
  set {
    name  = "ports.web.redirectTo"
    value = "websecure"
  }

  # Enable TLS on websecure
  set {
    name  = "ports.websecure.tls.enabled"
    value = "true"
  }
}
