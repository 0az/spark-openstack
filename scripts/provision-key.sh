#! /bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd || exit 1 )"

source "$scripts/_common.sh"
# shellcheck source=_ssh_args.sh
source "$scripts/_ssh_args.sh"

if ! test -r "$PRIVATE_KEY"; then
	PRIVATE_KEY="$scripts/../local/admin_ed25519"
fi

if ! test -e "$PRIVATE_KEY"; then
	echo 'Error: PRIVATE_KEY does not exist' >&2
	exit 1
fi

ssh "${ssh_args[@]}" -- /bin/bash <<EOF
	mkdir -p ~/.ssh
	umask 077
	touch ~/.ssh/admin_ed25519
EOF
ssh "${ssh_args[@]}" -- /bin/bash -eu \
	-c "cat > ~/.ssh/admin_ed25519" \
	< "$PRIVATE_KEY"

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
source local/admin-openrc.sh

ssh-keygen -y -f ~/.ssh/admin_ed25519 \
| awk '{ print $1, $2, "admin@ctl"; }' \
> ~/.ssh/admin_ed25519.pub

sudo cp -a ~/.ssh/admin_ed25519 /root/admin_ed25519
python scripts/_provision_key.py ~/.ssh/admin_ed25519.pub
EOF
