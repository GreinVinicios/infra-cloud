terraform {
  required_version = ">= 0.13.0"

  required_providers {
    civo = {
      source  = "civo/civo"
      version = "~> 1.0.18"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.18.0"
    }
  }
}

variable "civo_token" {
  type = string
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_global_key" {
  type = string
}

provider "civo" {
  token  = var.civo_token
  region = "NYC1"
}

provider "helm" {
  kubernetes {
    host                   = yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server
    client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)
    client_key             = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)
  }
}

provider "kubernetes" {
  host                   = yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)
}

provider "kubectl" {
  host                   = yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)
  load_config_file       = false
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_global_key
}
