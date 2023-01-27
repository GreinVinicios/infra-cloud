variable "location" {
  type        = string
  description = "(Required) String for GKE location."
}

variable "region" {
  type        = string
  description = "(Required) String for GKE region."
}

variable "network_self_link" {
  type = string
}

variable "subnetwork_self_link" {
  type = string
}
