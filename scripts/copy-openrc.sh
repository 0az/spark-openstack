#! /bin/bash

set -euo pipefail

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=_ssh_args.sh
source "$scripts/_ssh_args.sh"

exec ssh "${ssh_args[@]}" -- \
	sudo cat /root/setup/admin-openrc.sh \
> admin-openrc.sh
# ssh -T mgt-node.cloudlab.internal -- \
# 	tee spark-openstack/admin-openrc.sh \
# < admin-openrc.sh
