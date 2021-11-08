#! /bin/bash

# This file is read by bootstrap-spark-ansible.sh.

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
	ansible
	openstacksdk
	shade
)

tmpdir="$(mktemp -d)"

if test -d ~/spark-openstack -a -z "$RECREATE_VENV"; then 
	exit 1
fi

sudo apt-get update
sudo apt-get install "${apt_packages[@]}"

if test -d ~/spark-openstack/.venv -a -n "$RECREATE_VENV"; then
	rm -rf ~/spark-openstack/.venv
fi

if ! test -d ~/spark-openstack/.venv; then
	python3 -m venv ~/spark-openstack/.venv
fi

# shellcheck disable=SC1090
source ~/spark-openstack/.venv/bin/activate

pip install "${pip_packages[@]}"

# Create a more-or-less identical copy, permissions/owner-wise
# This lets us truncate and write to this file before an atomic move+replace
sudo cp -a /etc/hosts "$tmpdir/hosts"
# Create a writable copy as a buffer
cp "$tmpdir/hosts" "$tmpdir/hosts.txt"
echo '127.0.0.1 mgt-node' >> "$tmpdir/hosts.txt"
if ! grep -Ev 'ctl[.-]' /etc/hosts | grep -q ctl; then
	ip="$(getent ahosts "$(hostname)")"
	echo "$ip ctl" >> "$tmpdir/hosts.txt"
fi

python3 - <<EOF
import sys
if len(sys.argv) != 2:
    sys.exit(1)

d = {}
with open(sys.argv[1]) as f:
    for line in f:
        addr, *rest = line.split()
        l = d.setdefault(addr, [])
        for v in rest:
            if v not in l:
                l.append(v)

lines = sorted(d.items(), key=lambda t: tuple(map(int, t[0].split('.'))))
for addr, names in lines:
    print(f'{addr}\t{" ".join(names)}')
EOF

sudo mv "$tmpdir/hosts" /etc/hosts
