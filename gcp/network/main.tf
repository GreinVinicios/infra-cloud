#API
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_dependent_services = true
}

#VPC
resource "google_compute_network" "main" {
  name                            = "main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

#SUBNET
resource "google_compute_subnetwork" "private" {
  name                     = "private"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range = [ 
    {
      ip_cidr_range = "10.48.0.0/14"
      range_name = "k8s-pod-range"
    },
    {
      ip_cidr_range = "10.52.0.0/14"
      range_name = "k8s-service-range"
    } 
  ]
}

#ROUTER
resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.main.id
}

#NAT
resource "google_compute_address" "nat" {
  name = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.compute
  ]
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = [ "ALL_IP_RANGES" ]
  }

  nat_ips = [ google_compute_address.nat.self_link ]

  depends_on = [
    google_compute_address.nat
  ]
}

#FIREWALL
resource "google_compute_firewall" "allow-ssh" {
  name = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports = [ "22" ]
  }

  source_ranges = [ "0.0.0.0/0" ]
}
