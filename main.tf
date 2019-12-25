variable "project" {}
variable "credentials_file" {}
variable "region" {}
variable "zone" {}
variable "gce_ssh_user" {}
variable "ssh_keypair" {
    type = map
}

// Configure the Google Cloud provider
provider "google" {
 credentials = var.credentials_file
 project     = var.project
 region      = var.region
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "yams-vm"
 machine_type = "f1-micro"
 zone         = "us-west1-a"

 boot_disk {
   initialize_params {
     image = "gce-uefi-images/ubuntu-1804-lts"
   }
 }

 network_interface {
   network = "default"
 }
 metadata = {
    ssh-keys = var.ssh_keypair
  }
}

