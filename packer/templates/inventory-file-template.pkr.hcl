{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o IdentitiesOnly=yes'
