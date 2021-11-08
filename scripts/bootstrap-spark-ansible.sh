#! /bin/bash

set -euo pipefail

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
	echo 'USAGE'
	printf '\t%s <ssh-args ...>\n\n' "$0"
	echo 'All arguments are passed through to ssh(1).'
}

git_root="$(git rev-parse --show-toplevel 2>/dev/null || echo)"
git_remote='https://github.com/liside/spark-openstack.git'

if [[ -n "$git_root" ]]; then
	git_branch="$(git rev-parse --abbrev-ref HEAD)"
	if [[ "$git_branch" = HEAD ]]; then
		# Something weird's going on; bail
		echo 'Git HEAD is detached: aborting' >&2
		exit 1
	fi
	git_remote="$(git config branch."$git_branch".remote)"
	git_remote_url="$(git remote get-url "$git_remote")"
fi
clone_cmd=(git clone --depth=1 --single-branch)
if [[ -n "$git_branch" ]]; then
	clone_cmd+=(-b "$git_branch")
fi
clone_cmd+=("${git_remote_url/git@github.com:/https://github.com/}")

# shellcheck disable=SC2087
ssh "$@" -- /bin/bash <<-EOF
set -euo pipefail
if test -d ~/spark-openstack; then
	rm -rf spark-openstack
fi
${clone_cmd[@]}
EOF
ssh "$@" < "$scripts/_bootstrap-openstack-manager.sh"
