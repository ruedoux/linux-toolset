#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'
LOG_FILE="/tmp/arch-install.log"

setup_logging() {
  touch "$LOG_FILE"
  chmod 600 "$LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
  log_step "Logging to ${LOG_FILE}"
}

log_step() { echo -e "\n${BOLD}[$(date '+%H:%M:%S')] ▶ $*${RESET}"; }
log_ok()   { echo -e "${GREEN}  v $*${RESET}"; }
log_warn() { echo -e "${YELLOW}  w $*${RESET}"; }
log_err()  { echo -e "${RED}  x $*${RESET}" >&2; }

run_step() {
  local fn="$1"
  local message="$2"

  log_step "Started ${message}"
  if ! "$fn"; then
    log_err "FAILED: ${message}"
    exit 1
  fi
  log_ok "Finished ${message}"
}

pause_before_reboot() {
  local msg="${1:-Installation}"
  echo -e "\n${GREEN}${BOLD}----------------------------------------------${RESET}"
  echo -e "${GREEN}${BOLD}  ${msg} complete.${RESET}"
  echo -e "${GREEN}${BOLD}  Log saved to: ${LOG_FILE}${RESET}"
  echo -e "${GREEN}${BOLD}----------------------------------------------${RESET}\n"

  echo -e "Rebooting in 10 seconds... (Ctrl+C to cancel)"
  for i in {10..1}; do
    printf "  %2d\r" "$i"
    sleep 1
  done
  echo ""
  log_step "Rebooting now"
  reboot
}

parse_kernels() {
  IFS=' ' read -ra KERNEL_LIST <<< "$KERNELS"
  IFS='|' read -ra LABEL_LIST  <<< "$EFI_LABELS"

  if [[ ${#KERNEL_LIST[@]} -ne ${#LABEL_LIST[@]} ]]; then
    log_err "KERNELS count (${#KERNEL_LIST[@]}) does not match EFI_LABELS count (${#LABEL_LIST[@]})"
    exit 1
  fi
}

verify_checked() {
  if [ "$CHECKED" != "true" ]; then
    log_err "Variable 'CHECKED' was not set to 'true' in 'settings.env' file"
    log_err "Please check the settings before running"
    exit 1
  fi
}

# Passwords are provided via environment variables:
#   SETUP_LUKS_PASSWORD          – LUKS encryption passphrase
#   SETUP_ROOT_PASSWORD          – root password (empty = lock root)
#   SETUP_PASSWORD_<username>    – per-user password
collect_passwords() {
  local phase="${1:-base}"

  local expected=()
  local users=()

  if [[ "$phase" == "base" ]]; then
    expected+=("SETUP_LUKS_PASSWORD")
    expected+=("SETUP_ROOT_PASSWORD")
  fi

  users+=("$ADMIN_USER")
  for entry in "${DESKTOP_USERS[@]}"; do
    local username="${entry%%:*}"
    users+=("$username")
  done

  local unique_users=($(printf '%s\n' "${users[@]}" | sort -u))
  for user in "${unique_users[@]}"; do
    expected+=("SETUP_PASSWORD_${user}")
  done

  local missing=false
  for key in "${expected[@]}"; do
    if [[ -z "${!key:-}" ]]; then
      missing=true
      break
    fi
  done

  if ! $missing; then
    log_ok "All passwords provided via environment variables"
    return 0
  fi

  echo ""
  log_step "Password collection"
  echo ""

  for key in "${expected[@]}"; do
    if [[ -n "${!key:-}" ]]; then
      continue  # already set via env
    fi

    local prompt_label
    case "$key" in
      SETUP_LUKS_PASSWORD)
        prompt_label="LUKS encryption passphrase"
        ;;
      SETUP_ROOT_PASSWORD)
        prompt_label="Root password (leave empty to lock root)"
        ;;
      SETUP_PASSWORD_*)
        local user="${key#SETUP_PASSWORD_}"
        prompt_label="Password for user '${user}'"
        ;;
    esac

    local password
    read -rsp "  ${prompt_label}: " password
    echo ""
    printf -v "$key" '%s' "$password"
    export "$key"
  done

  log_ok "Passwords collected"
}

set_password_noninteractive() {
  local username="$1"
  local password="$2"

  if [[ -z "$password" ]]; then
    return 1
  fi

  if [[ $EUID -ne 0 ]]; then
    echo "${username}:${password}" | sudo chpasswd
  else
    echo "${username}:${password}" | chpasswd
  fi
  log_ok "Password set for ${username}"
  return 0
}

prime_sudo_cache() {
  if [[ $EUID -eq 0 ]]; then
    return 0
  fi
  local key="SETUP_PASSWORD_${ADMIN_USER}"
  local admin_pass="${!key:-}"
  if [[ -n "$admin_pass" ]]; then
    echo "$admin_pass" | sudo -S -v 2>/dev/null
    log_ok "Sudo credentials cached for ${ADMIN_USER}"
  fi
}

cleanup_sudo() { sudo -k 2>/dev/null || true; }
