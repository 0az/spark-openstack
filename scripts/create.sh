#! /bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$scripts/_common.sh"

exec ssh "$@" /bin/bash <<EOF
test -a ~/spark-openstack/spark-openstack \
&& ~/spark-openstack/spark-openstack \
	--create \
	--deploy-spark \
	-k admin \
	-s 1 \
	-n flat-lan-1-net \
	-t m1.xlarge \
	-m m1.xlarge \
	-a focal-server-cloudimg-amd64  \
	--spark-version 2.4.4 \
	launch test-project
EOF
