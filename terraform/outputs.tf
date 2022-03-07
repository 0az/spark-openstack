output "admin-key" {
  value = {
    name        = openstack_compute_keypair_v2.admin-key.name
    fingerprint = openstack_compute_keypair_v2.admin-key.fingerprint
    public-key  = openstack_compute_keypair_v2.admin-key.public_key
  }
}

output "spark-managers" {
  value = [for node in openstack_compute_instance_v2.spark-manager :
    {
      name            = node.name
      ipv4            = node.access_ip_v4
      security_groups = node.security_groups
      networks = zipmap(
        node.network[*].name,
        node.network[*].fixed_ip_v4,
      )
    }
  ]
}

output "spark-workers" {
  value = [for node in openstack_compute_instance_v2.spark-worker :
    {
      name            = node.name
      ipv4            = node.access_ip_v4
      security_groups = node.security_groups
      networks = zipmap(
        node.network[*].name,
        node.network[*].fixed_ip_v4,
      )
    }
  ]
}
