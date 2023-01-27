module "network" {
  source = "./network"
  region = var.region
}
module "gke" {
  source = "./gke"
  location = var.location
  region = var.region

  network_self_link = module.network.network_self_link
  subnetwork_self_link = module.network.subnetwork_self_link

  depends_on = [
    module.network
  ]
}

variable "location" {
  type        = string
  description = "(Required) String for GKE location."
}
