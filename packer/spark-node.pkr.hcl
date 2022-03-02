packer {
  required_plugins {
    openstack = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

variable "openstack-flavor" {
  type = string
}
variable "openstack-network" {
  type = string
}
variable "openstack-external-network" {
  type = string
}

variable "openstack-keypair-name" {
  type = string
  default = "admin"
}
variable "openstack-private-key-file" {
  type = string
}

variable "bastion-host" {
  type = string
}
variable "bastion-user" {
  type = string
}
variable "bastion-private-key-file" {
  type = string
}

locals {
  root = abspath(path.root)
}

source "openstack" "ubuntu" {
  image_name = "spark-node"
  source_image_name = "focal-server-cloudimg-amd64"
  ssh_username = "ubuntu"
  flavor = var.openstack-flavor
  floating_ip_network = var.openstack-external-network
  networks = [var.openstack-network]
  communicator = "ssh"
  ssh_keypair_name = var.openstack-keypair-name
  ssh_private_key_file = var.openstack-private-key-file
  ssh_bastion_host = var.bastion-host
  ssh_bastion_username = var.bastion-user
  ssh_bastion_private_key_file = var.bastion-private-key-file
  ssh_timeout = "1m"
}

build {
  name = "spark-node"
  sources = [
    "source.openstack.ubuntu",
  ]
  provisioner "ansible" {
    command = "${path.root}/ansible-wrapper.sh"
    playbook_file = "${path.root}/../ansible/build-image.yml"
    user = "ubuntu"
    # ansible_ssh_extra_args = [
    #   "-o",
    #   "IdentitiesOnly=yes",
    #   "-i",
    #   var.openstack-private-key-file,
    # ]
    extra_arguments = ["-vv"]
    inventory_directory = "/tmp"
    inventory_file_template = templatefile(
      "${abspath(path.root)}/templates/inventory-file-template.pkr.hcl",
      {
        bastion-user = var.bastion-user,
        bastion-host = var.bastion-host,
        keys = [
          var.openstack-private-key-file,
          var.bastion-private-key-file,
        ]
      }
    )
    use_proxy = false
  }
}
