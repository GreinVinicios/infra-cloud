#CLUSTER Primary
resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = var.location

  remove_default_node_pool = true
  initial_node_count       = 1

  network                  = var.network_self_link
  subnetwork               = var.subnetwork_self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  node_locations = [ "us-west1-b" ]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "devops-358519.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

#NODE-POOLS
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.primary.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  node_config {
    preemptible = true
    machine_type = "e2-medium"

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# resource "google_container_node_pool" "spot" {
#   name       = "spot"
#   cluster    = google_container_cluster.primary.id
#   node_count = 1

#   management {
#     auto_repair  = true
#     auto_upgrade = true
#   }

#   autoscaling {
#     min_node_count = 0
#     max_node_count = 10
#   }

#   node_config {
#     preemptible = true
#     machine_type = "e2-small"

#     labels = {
#       team = "devops"
#     }

#     # taint = [ {
#     #   effect = "NO_SCHEDULE"
#     #   key = "instance_type"
#     #   value = "spot"
#     # } ]

#     service_account = google_service_account.kubernetes.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }


##########################
#CLUSTER autopilot
# resource "google_container_cluster" "autopilot" {
#   name                     = "autopilot"
#   location                 = var.region

#   enable_autopilot = true

#   initial_node_count       = 1

#   network                  = var.network_self_link
#   subnetwork               = var.subnetwork_self_link
#   networking_mode          = "VPC_NATIVE"

#   addons_config {
#     horizontal_pod_autoscaling {
#       disabled = false
#     }
#   }

#   release_channel {
#     channel = "REGULAR"
#   }

#   ip_allocation_policy {
#     cluster_secondary_range_name  = "k8s-pod-range"
#     services_secondary_range_name = "k8s-service-range"
#   }

#   private_cluster_config {
#     enable_private_nodes    = true
#     enable_private_endpoint = false
#     master_ipv4_cidr_block  = "172.16.0.0/28"
#   }
# }
