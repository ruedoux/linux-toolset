#!/bin/bash
set -euo pipefail

SETUP_SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
export SETUP_SCRIPT_DIR

source "$SETUP_SCRIPT_DIR/settings.env"
source "$SETUP_SCRIPT_DIR/.lib.sh"

verify_checked

usage() {
  local script_name
  script_name="$(basename "${BASH_SOURCE[0]:-$0}")"
  echo "Usage:"
  echo "  $script_name base"
  echo "  $script_name post-install"
}

case "${1:-}" in
  base)
    collect_passwords "$1"
    echo "Target disk: ${DRIVE} — will be wiped."
    lsblk -o NAME,SIZE,MODEL,TYPE "$DRIVE" 2>/dev/null || true
    echo ""
    "$SETUP_SCRIPT_DIR/scripts/arch-install.sh"
    ;;
  post-install)
    collect_passwords "$1"
    "$SETUP_SCRIPT_DIR/scripts/desktop-env-setup.sh"
    ;;
  *)
    usage
    exit 1
    ;;
esac
