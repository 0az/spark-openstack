#! /bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=_common.sh
source "$scripts/_common.sh"
# shellcheck source=_ssh_args.sh
source "$scripts/_ssh_args.sh"

# shellcheck disable=SC2087
exec ssh "${ssh_args[@]}" -- /bin/bash <<EOF
cd ~/spark-openstack || exit 2

git pull
EOF
