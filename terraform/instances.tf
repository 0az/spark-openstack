data "openstack_images_image_v2" "spark-node" {
  name        = "spark-node"
  most_recent = true
}

data "openstack_compute_flavor_v2" "spark-custom" {
  name = "spark.custom"
}

resource "openstack_compute_keypair_v2" "admin-key" {
  name       = "admin"
  public_key = trimspace(file("${path.root}/../local/admin_ed25519.pub"))
}

resource "openstack_compute_instance_v2" "spark-manager" {
  count = 1

  name      = "spark-manager-${count.index}"
  image_id  = data.openstack_images_image_v2.spark-node.id
  flavor_id = data.openstack_compute_flavor_v2.spark-custom.id
  key_pair  = openstack_compute_keypair_v2.admin-key.name
  tags      = ["spark-manager"]
  # security_groups = []

  network {
    name = "flat-lan-1-net"
  }
}

resource "openstack_compute_instance_v2" "spark-worker" {
  count = var.workers

  name      = "spark-worker-${count.index}"
  image_id  = data.openstack_images_image_v2.spark-node.id
  flavor_id = data.openstack_compute_flavor_v2.spark-custom.id
  key_pair  = openstack_compute_keypair_v2.admin-key.name
  tags      = ["spark-worker"]
  # security_groups = []

  network {
    name = "flat-lan-1-net"
  }
}

resource "local_file" "ansible-inventory" {
  filename = "hosts.ini"
  content = templatefile(
    "${path.root}/templates/terraform-hosts.ini.tftpl",
    {
      managers = openstack_compute_instance_v2.spark-manager
      workers  = openstack_compute_instance_v2.spark-worker
      ansible-bastion = {
        host = var.ansible-bastion-host
        user = var.ansible-bastion-user
      }
      identity-files = [for file in var.ansible-identity-files :
        abspath(file)
      ]
    }
  )
  file_permission = "0644"
}
