#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
. "${SCRIPT_DIR}/toolset-global.sh"

create_alert() {
  local alert_dir="$1"
  local alert_message="$2"
  local time_stamp=$(date +"%Y-%m-%d_%H-%M-%S-%3N")
  local alert_file="$alert_dir/$time_stamp.alert"

  mkdir -p "$alert_dir"
  printf "%b" "$alert_message" > "$alert_file"
}

list_alerts() {
  local alert_dir="$1"

  mkdir -p "$alert_dir"
  shopt -s nullglob

  local alerts=("$alert_dir"/*.alert)
  if [ ${#alerts[@]} -eq 0 ]; then
    info "No alerts found."
    echo
    return
  fi

  for alert in "${alerts[@]}"; do
    echo -e "${alert_dir}/${RED_COLOR}$(basename "$alert")${NO_COLOR}"
    cat "$alert"
    echo
  done
}

create_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local alert_dir=""
  local alert_message=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        alert_dir="$2"
        shift 2
        ;;
      -m|--message)
        alert_message="$2"
        shift 2
        ;;
      -*)
        echo "Unknown option: $1"
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ -z "$alert_dir" || -z "$alert_message" ]]; then
      echo "Usage: . $SCRIPT_NAME create --dir <dir> --message <message>"
      return 1
  fi

  create_alert "$alert_dir" "$alert_message"
}

list_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local alert_dir=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        alert_dir="$2"
        shift 2
        ;;
      -*)
        echo "Unknown option: $1"
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ -z "$alert_dir" ]]; then
      echo "Usage: $SCRIPT_NAME list --dir <dir>"
      return 1
  fi

  list_alerts "$alert_dir"
}

case "$1" in
  create)
    shift
    create_entry "$@"
    ;;
  list)
    shift
    list_entry "$@"
    ;;
  *)
    SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
    echo "Usage: $SCRIPT_NAME [create|list]"
    exit 1
    ;;
esac