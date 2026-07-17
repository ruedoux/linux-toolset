#!/bin/bash

. "${TOOLSET_SCRIPT_DIR}/global.sh"

maintain_btrfs() {
  read -p "Provide drive path: " drive_path
  info "Balancing and scrubbing disk $drive_path"
  sudo btrfs balance start -dusage=85 $drive_path
  sudo btrfs scrub start $drive_path
  watch "sudo btrfs scrub status ${drive_path}"
}

display_used_ports() {
  info "Listing open ports via 'ss -lpntu'"
  sudo  ss -lpntu

  info "Listing open ports via 'netstat -lpntu'"
  sudo netstat -lpntu
}

check_dangling() {
  info "Dangling dependencies, remove using pacman -Rcns"
  pacman -Qtd
  
  local home_dirs=$(awk -F: '{if($6 ~ /^\/home\// || $6 == "/root") print $6}' /etc/passwd | sort -u)
  local excludes=$(printf '|%s' $home_dirs)
  local excludes=${excludes:1}

  info "Broken symlinks"
  sudo find / -type d \( -path "/dev" -o -path "/proc" -o -path "/run" -o -path "/sys" \) -prune -o -xtype l -print | grep -Ev "^($excludes)"
}

main() {
  ALLOWED_FUNCTIONS="maintain_btrfs display_used_ports check_dangling"
  if [ -z "$1" ]; then
    info "Available functions:"
    for fn in $ALLOWED_FUNCTIONS; do
      echo "$fn"
    done
    exit 0
  fi
  if [[ " $ALLOWED_FUNCTIONS " =~ " $1 " ]]; then
    "$@"
  else
    error "Function '$1' not found or not allowed."
    exit 1
  fi
}

main "$@"
