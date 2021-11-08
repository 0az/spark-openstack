#! /bin/bash

usage() {
	echo 'USAGE'
	printf '\t%s <ssh-args ...>\n\n' "$0"
	declare -F extra_usage >/dev/null && extra_usage && echo
	echo 'All arguments are passed through to ssh(1).'
}

if [[ "$#" -lt 1 ]]; then
	usage >&2
	exit 1
fi

_check_help() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-h|--help)
				usage >&2
				exit 0
				;;
			--)
				return 0
				;;
			*)
				shift
				;;
		esac
	done
}

_check_help "$@"
