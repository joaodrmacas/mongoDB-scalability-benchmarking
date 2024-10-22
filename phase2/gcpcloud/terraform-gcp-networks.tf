
# Elemets of the cloud such as virtual servers,
# networks, firewall rules are created as resources
# syntax is: resource RESOURCE_TYPE RESOURCE_NAME
# https://www.terraform.io/docs/configuration/resources.html

resource "google_compute_firewall" "frontend_rules" {
  name    = "frontend"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["1-32767"]  # Include NodePort range
  }

  source_ranges = ["0.0.0.0/0"]  # Allows access from any IP
  target_tags   = ["worker","master"]
}
