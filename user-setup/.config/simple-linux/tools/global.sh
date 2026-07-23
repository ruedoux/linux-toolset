#!/bin/bash

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
BLUE_COLOR='\033[0;34m'
PURPLE_COLOR='\033[0;35m'
NO_COLOR='\033[0m'

# Source config.env if it exists (relative to the tools/ directory)
SL_ROOT_DIR="${SL_ROOT_DIR:-$(dirname "$TOOLSET_SCRIPT_DIR")}"
SL_CONFIG_PATH="${SL_CONFIG_PATH:-$SL_ROOT_DIR/config.env}"
if [ -f "$SL_CONFIG_PATH" ]; then
    set -a; source "$SL_CONFIG_PATH"; set +a
fi

toolset.require_var() {
    local var_name="$1"
    if [ -z "${!var_name:-}" ]; then
        error "Variable $var_name is not set. Please add it to ${SL_CONFIG_PATH:-config.env}"
        return 1
    fi
}

info() { echo -e "${BLUE_COLOR}[INFO]${NO_COLOR} $@"; }
error() { echo -e "${RED_COLOR}[ERROR]${NO_COLOR} $@"; }
debug() {
  if [[ -n "${TOOLSET_DEBUG:-}" ]]; then
    echo -e "${PURPLE_COLOR}[DEBUG]${NO_COLOR} $@"
  fi
}

toolset.set_if_exists() {
  [ -f "$1" ] && printf '%s\n' "$1"
}

# Pulls config file path from provided args and verifies file exists. Usage:
# file_path=$(get_config_from_args $@) || { echo error; return 1; }
toolset.get_config_file_from_args() {
  local config_file_path=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--config)
        shift
        config_file_path="$1"
        ;;
    esac
    shift
  done

  if [[ -z "$config_file_path" ]]; then
    error "Error: --config option is required." >&2
    return 1
  fi

  if [[ ! -f "$config_file_path" ]]; then
    error "Error: Config file '$config_file_path' does not exist." >&2
    return 1
  fi

  readlink -f "$config_file_path"
}

toolset.verify_config() {
  local config_path="$1"
  shift
  for var in "$@"; do
    grep -q "^$var=" "$config_path" || { error "Variable $var not found in $config_path" >&2; return 1; }
  done
}

toolset.verify_json_config() {
  local config_path="$1"
  shift

  for path in "$@"; do
    jq -e ".$path" "$config_path" > /dev/null 2>&1 || {
      error "Path $path not found in $config_path" >&2
      return 1
    }
  done
}

toolset.update_config_variable() {
  local config_file_path="$1"
  local var_name="$2"
  local var_value="$3"

  if [[ ! -f "$config_file_path" ]]; then
    error "Config file '$config_file_path' does not exist." >&2
    return 1
  fi

  if [ -z "${var_name+x}" ]; then
    error "Variable name not provided" >&2
    return 1
  fi

  sed -i "s|^${var_name}=.*|${var_name}=\"${var_value}\"|" "$config_file_path"
}

toolset.verify_variable_exists() {
  local var_name="$1"
  if [ -z "${!var_name+x}" ]; then
    error "Variable $var_name not set" >&2
    return 1
  fi
}