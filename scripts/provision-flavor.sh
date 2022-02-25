#! /bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd || exit 1 )"

source "$scripts/_common.sh"
# shellcheck source=_ssh_args.sh
source "$scripts/_ssh_args.sh"

exec ssh "${ssh_args[@]}" -- /bin/bash -euo pipefail <<'EOF'
cd ~/spark-openstack >/dev/null || exit 2

if ! test \
	-a ./spark-openstack \
	-a -a .venv/bin/activate \
; then
	echo 'Virtual environment or entrypoint not found' >&2
	exit 3
fi

source .venv/bin/activate
source admin-openrc.sh

python scripts/_provision_flavor.py
EOF
