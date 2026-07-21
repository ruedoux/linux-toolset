#!/bin/bash
set -euo pipefail

export TOOLSET_SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"

usage() {
  echo "Usage: ${SCRIPT_NAME} <subcommand> [args...]"
  echo ""
  echo "Available subcommands:"
  for script in "${TOOLSET_SCRIPT_DIR}/commands/"*.sh; do
    name="$(basename "$script")"
    name="${name#toolset-}"
    name="${name%.sh}"
    [[ "$name" == "global" ]] && continue
    echo "  ${name}"
  done
}

cmd="${1:-}"
script="${TOOLSET_SCRIPT_DIR}/commands/${cmd}.sh"

if [[ -z "$cmd" || ! -x "$script" ]]; then
  usage
  return 1
fi

shift
exec "$script" "$@"
