#! /bin/bash

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "$root/terraform"

exec terraform "$@"
