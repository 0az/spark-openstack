#! /bin/bash
scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd || exit 1 )"

usage() {
	echo 'USAGE'
	printf '\t%s <ssh-args ...>\n\n' "$0"
	echo 'All arguments are passed through to ssh(1).'
}

if [[ "$#" -ne 1 ]]; then
	usage >&2
	exit 1
fi

ssh "$@" < "$scripts/_fix-keystone.sh"
