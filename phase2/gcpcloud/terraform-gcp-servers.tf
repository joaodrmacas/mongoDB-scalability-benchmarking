
# Elemets of the cloud such as virtual servers,
# networks, firewall rules are created as resources
# syntax is: resource RESOURCE_TYPE RESOURCE_NAME
# https://www.terraform.io/docs/configuration/resources.html

###########  Web Servers   #############
resource "google_compute_instance" "worker" {
    count = 5
    name = "worker${count.index+1}"
    machine_type = var.GCP_MACHINE_TYPE
    allow_stopping_for_update = true
    zone = lookup(
        {
            0 = var.GCP_ZONE
            1 = var.GCP_ZONE
            2 = var.GCP_ZONE
            3 = var.GCP_ZONE
            4 = var.GCP_ZONE
        },
        count.index,
        var.GCP_ZONE
    )

    boot_disk {
        initialize_params {
            image = "ubuntu-2004-focal-v20240830"
        }
    }

    network_interface {
        network = "default"
        access_config {
        }
    }

    metadata = {
      ssh-keys = "ubuntu:${file("/home/vagrant/.ssh/id_rsa.pub")}"
    }
  
    tags = ["worker"]
}



###########  Master   #############
resource "google_compute_instance" "master" {
    name = "master"
    machine_type = var.GCP_MACHINE_TYPE
    allow_stopping_for_update = true  # Add this line
    zone = var.GCP_ZONE

    boot_disk {
        initialize_params {
        # image list can be found at:
        # https://console.cloud.google.com/compute/images
        image = "ubuntu-2004-focal-v20240830"
        }
    }

    network_interface {
        network = "default"
        access_config {
        }
    }

    metadata = {
      ssh-keys = "ubuntu:${file("/home/vagrant/.ssh/id_rsa.pub")}"
    }

  tags = ["master"]
}

