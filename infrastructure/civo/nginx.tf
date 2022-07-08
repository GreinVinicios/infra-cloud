resource "kubernetes_namespace" "nginx" {

  depends_on = [
    time_sleep.wait_for_kubernetes
  ]

  metadata {
    name = "nginx"
  }
}

resource "kubernetes_deployment" "nginx" {
  depends_on = [
    kubernetes_namespace.nginx
  ]

  metadata {
    name      = "nginx-deploy"
    namespace = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  depends_on = [
    kubernetes_namespace.nginx
  ]

  metadata {
    name      = "nginx-svc"
    namespace = "nginx"
  }
  spec {
    selector = {
      "app" = "nginx"
    }
    port {
      port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubectl_manifest" "nginx-certificate" {

  depends_on = [kubernetes_namespace.nginx, time_sleep.wait_for_clusterissuer]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx
  namespace: nginx
spec:
  secretName: nginx
  issuerRef:
    name: cloudflare-prod
    kind: ClusterIssuer
  dnsNames:
  - '<yoursubdomain.yourdomain>'   
    YAML
}

resource "kubernetes_ingress_v1" "nginx" {
  depends_on = [
    kubernetes_namespace.nginx
  ]

  metadata {
    name      = "nginx-ingress"
    namespace = "nginx"
  }

  spec {
    rule {
      host = "<yoursubdomain.yourdomain>"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "nginx-svc"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "nginx"
      hosts       = ["<yoursubdomain.yourdomain>"]
    }
  }
}

resource "cloudflare_record" "my-main-cluster" {
  zone_id = "<CoudFlare_zoneId>"
  name    = "<yoursubdomain.yourdomain>"
  value   = data.civo_loadbalancer.traefik_lb.public_ip
  type    = "A"
  proxied = false
}
