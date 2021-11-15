#! /bin/bash

# This file is read by bootstrap-spark-ansible.sh
# and executed on the remote OpenStack manager node.

set -euo pipefail

apt_packages=(
	libffi-dev
	libssl-dev
	python3-dev
	python3-pip
	python3-venv
	python3-wheel
)
pip_packages=(
	'ansible ~=2.9.0, <3.0'
	openstacksdk
	shade
)

repo=~/spark-openstack
tmp="$(mktemp -d)"

sudo apt-get update
sudo apt-get install "${apt_packages[@]}"

if test -d "$repo/.venv" -a -n "${RECREATE_VENV:-}"; then
	rm -rf "$repo/.venv"
fi

if ! test -d "$repo/.venv"; then
	python3 -m venv "$repo/.venv"
fi

# shellcheck disable=SC1091
source "$repo/.venv/bin/activate"

pip install -U pip wheel
pip install -U "${pip_packages[@]}"

# Create a more-or-less identical copy, permissions/owner-wise
# This lets us truncate and write to this file before an atomic move+replace
sudo cp -a /etc/hosts "$tmp/hosts"
# Create a writable copy as a buffer
cp "$tmp/hosts" "$tmp/hosts.txt"
echo '127.0.0.1 mgt-node' >> "$tmp/hosts.txt"
if ! grep -Ev 'ctl[.-]' /etc/hosts | grep -q ctl; then
	ip="$(getent ahosts "$(hostname)")"
	echo "$ip ctl" >> "$tmp/hosts.txt"
fi

cat > "$tmp/coalesce_hosts.py" <<EOF
import sys
if len(sys.argv) != 2:
    sys.exit(1)

d = {}
with open(sys.argv[1]) as f:
    for line in f:
		if not line:
			continue
        addr, *rest = line.split()
        l = d.setdefault(addr, [])
        for v in rest:
            if v not in l:
                l.append(v)

lines = sorted(d.items(), key=lambda t: tuple(map(int, t[0].split('.'))))
for addr, names in lines:
    print(f'{addr}\t{" ".join(names)}')
EOF

python3 "$tmp/coalesce_hosts.py" "$tmp/hosts.txt" | sudo tee "$tmp/hosts"

sudo mv "$tmp/hosts" /etc/hosts

# shellcheck disable=SC2024

(
	umask 077
	sudo cat /root/setup/admin-openrc.sh > "$tmp/admin-openrc.sh"
	mv "$tmp/admin-openrc.sh" "$repo"
)
