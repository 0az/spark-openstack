#! /bin/bash

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

export ANSIBLE_CONFIG="$root/ansible/ansible.cfg"
export ANSIBLE_STDOUT_CALLBACK=community.general.dense

exec \
	ansible-playbook \
	-i "$root/terraform/hosts.ini" \
	--forks 10 \
	"$@" \
;
