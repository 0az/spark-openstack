#! /bin/bash

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

# shellcheck disable=SC1091
source "$root/.venv/bin/activate"

export ANSIBLE_FORCE_COLOR=1
export PYTHONUNBUFFERED=1

exec ansible-playbook "$@"
