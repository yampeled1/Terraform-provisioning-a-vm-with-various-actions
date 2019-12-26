variable "project" {}
variable "credentials_file" {}
variable "region" {}
variable "zone" {}
variable "gce_ssh_user" {}
variable "gce_ssh_pub_key" {}

// Configure the Google Cloud provider
provider "google" {
 credentials = var.credentials_file
 project     = var.project
 region      = var.region
}

// Adding VPC which I will be using for instance firewall
resource "google_compute_network" "vpc_network" {
  name = "gcp-vpc"
}

// Adding custom firewall rules as requested
resource "google_compute_firewall" "public_firewall" {
 name    = "exercise-public-firewall"
 network = google_compute_network.vpc_network.name

 allow {
   protocol = "tcp"
   ports    = ["22", "80", "443"]
 }

 source_ranges = ["0.0.0.0/0"]
 target_tags = ["public"]
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "yams-vm"
 machine_type = "f1-micro"
 zone         = "us-west1-a"
 tags = ["public"]
  labels       = {
      team = "devops"
  }

 boot_disk {
   initialize_params {
     image = "gce-uefi-images/ubuntu-1804-lts"
   }
 }

 network_interface {
   network = google_compute_network.vpc_network.name
    access_config {
    }
 }

 metadata = {
    ssh-keys = "${var.gce_ssh_user}:${var.gce_ssh_pub_key}"
  }
}

// Adding storage
resource "google_storage_bucket" "default" {
  name         = "yams_bucket"
  location = "us-west1"
}