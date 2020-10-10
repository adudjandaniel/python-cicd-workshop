variable "project_name" {
  type = string
  default = "addserver"
}

variable "port_number" {
  type = string
  default = "80"
}

variable "docker_declaration" {
  type = string
  # Change the image: string to match the docker image you want to use
  default = "spec:\n  containers:\n    - name: test-docker\n      image: 'adddanny/python-cicd-workshop'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
}

variable "boot_image_name" {
  type = string
  default = "projects/cos-cloud/global/images/cos-stable-69-10895-62-0"
}

data "google_compute_network" "default" {
  name = "default"
}

# Specify the provider (GCP, AWS, Azure)
provider "google"{
  credentials = file("terraform-tut-cred.json")
  project = var.project_name
  region = "us-central1"
}

resource "google_compute_firewall" "http-80" {
  name    = "http-80"
  network = data.google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.port_number]
  }
}

resource "google_compute_instance" "default" {
  name = "default"
  machine_type = "g1-small"
  zone = "us-central1-c"
  tags =[
      "name","default"
  ]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.boot_image_name
      type = "pd-standard"
    }
  }

  metadata = {
    gce-container-declaration = var.docker_declaration
  }

  labels = {
    container-vm = "cos-stable-69-10895-62-0"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

output "Public_IP_Address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
