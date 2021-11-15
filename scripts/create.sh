#! /bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

extra_usage() {
	echo 'To specify an OpenStack SSH key, set the KEY environment variable.'
}

source "$scripts/_common.sh"

# shellcheck disable=SC2087
exec ssh "$@" /bin/bash <<EOF
set -euo pipefail

cd ~/spark-openstack >/dev/null || exit 2

if ! test \
	-a ./spark-openstack \
	-a -a .venv/bin/activate \
; then
	echo 'Virtual environment or entrypoint not found' >&2
	exit 3
fi

source .venv/bin/activate

./spark-openstack \
	--create \
	--deploy-spark \
	-k "$KEY" \
	-s 1 \
	-n flat-lan-1-net \
	-t m1.xlarge \
	-m m1.xlarge \
	-a focal-server-cloudimg-amd64  \
	--spark-version 2.4.8 \
	launch test-project
EOF
