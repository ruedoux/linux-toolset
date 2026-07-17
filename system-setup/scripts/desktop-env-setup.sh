#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SETUP_SCRIPT_DIR="${SETUP_SCRIPT_DIR:-$(dirname "$SCRIPT_DIR")}"

source "$SETUP_SCRIPT_DIR/settings.env"
source "$SETUP_SCRIPT_DIR/.lib.sh"

verify_checked

sync_pacman() { sudo pacman -Syu --noconfirm; }

detect_and_install_gpu_drivers() {
  local gpu_vendors drivers=""
  gpu_vendors=$(lspci -mm 2>/dev/null | grep -iE '"(VGA compatible controller|3D controller|Display controller)"' | cut -d '"' -f4 || true)

  if echo "$gpu_vendors" | grep -qi "intel"; then
    drivers="$drivers mesa vulkan-intel intel-media-driver"
  fi
  if echo "$gpu_vendors" | grep -qiE "amd|advanced micro|ati"; then
    drivers="$drivers mesa vulkan-radeon libva-mesa-driver"
  fi
  if echo "$gpu_vendors" | grep -qi "nvidia"; then
    drivers="$drivers ${NVIDIA_DRIVER} nvidia-utils"
  fi

  if [[ -n "$drivers" ]]; then
    log_ok "Detected GPU(s), installing:${drivers}"
    # shellcheck disable=SC2086
    sudo pacman -S --noconfirm $drivers
  else
    log_warn "No recognized GPU; installing mesa as fallback"
    sudo pacman -S --noconfirm mesa
  fi
}

# shellcheck disable=SC2086
install_hyprland() { sudo pacman -S --noconfirm $HYPRLAND_PACKAGES; }
# shellcheck disable=SC2086
install_packages() { sudo pacman -S --noconfirm $OTHER_PACKAGES; }

create_desktop_users() {
  local entry username groups
  for entry in "${DESKTOP_USERS[@]}"; do
    username="${entry%%:*}"
    groups="${entry#*:}"

    if id -u "$username" &>/dev/null; then
      log_warn "User '${username}' already exists, skipping creation"
      continue
    fi

    sudo useradd -mG "$groups" "$username"

    local key="SETUP_PASSWORD_${username}"
    local user_password="${!key:-}"
    if ! set_password_noninteractive "$username" "$user_password"; then
      log_err "Password for ${username} not provided (SETUP_PASSWORD_${username})"
      exit 1
    fi
  done
}

enable_system_services() {
  # shellcheck disable=SC2086
  sudo systemctl enable --now $SYSTEMD_SYSTEM_SERVICES

  local entry username uid
  for entry in "${DESKTOP_USERS[@]}"; do
    username="${entry%%:*}"

    if ! id -u "$username" &>/dev/null; then
      log_warn "User '${username}' not found, skipping user services"
      continue
    fi

    uid="$(id -u "$username")"
    sudo loginctl enable-linger "$username"
    sudo systemctl start "user@${uid}.service"
  done
}

verify_secure_boot_mode() {
  if ! sudo sbctl status 2>/dev/null | grep -qi "setup mode.*enabled"; then
    log_err "Secure Boot is NOT in Setup Mode."
    log_err "Enter your BIOS/UEFI firmware, enable Setup Mode, then re-run this script."
    exit 1
  fi
  log_ok "Secure Boot Setup Mode confirmed"
}

setup_keys() {
  sudo sbctl create-keys
  sudo sbctl enroll-keys -m
}

sign_kernel_images() {
  IFS=' ' read -ra KERNEL_LIST <<< "$KERNELS"
  for kernel in "${KERNEL_LIST[@]}"; do
    sudo sbctl sign -s "/boot/EFI/Linux/arch-${kernel}.efi"
  done
}

install_resign_hook() {
  parse_kernels
  {
    echo "[Trigger]"
    echo "Operation = Upgrade"
    echo "Operation = Install"
    echo "Type = Package"
    for kernel in "${KERNEL_LIST[@]}"; do
      echo "Target = ${kernel}"
    done
    echo ""
    echo "[Action]"
    echo "Description = Re-signing UKI images for Secure Boot (sbctl)..."
    echo "When = PostTransaction"
    echo "Exec = /usr/bin/sbctl sign-all"
  } | sudo tee /etc/pacman.d/hooks/95-sbctl-sign.hook > /dev/null
}

main() {
  trap 'sudo -k 2>/dev/null || true' EXIT INT TERM
  setup_logging
  prime_sudo_cache

  # Desktop environment
  run_step sync_pacman                  "synchronizing pacman"
  run_step detect_and_install_gpu_drivers "detecting and installing GPU drivers"
  run_step create_desktop_users         "creating desktop users"
  run_step install_hyprland         "installing hyprland"
  run_step install_packages         "installing packages"
  run_step enable_system_services   "enabling system services"

  # Secure Boot
  run_step verify_secure_boot_mode  "checking Secure Boot Setup Mode"
  run_step setup_keys               "generating and enrolling Secure Boot keys"
  run_step sign_kernel_images       "signing UKI images"
  run_step install_resign_hook      "installing pacman auto-resign hook"

  pause_before_reboot "System setup"
}

main
