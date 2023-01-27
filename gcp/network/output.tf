output "network_self_link" {
  value = google_compute_network.main.self_link
}

output "subnetwork_self_link" {
  value = google_compute_subnetwork.private.self_link
}
