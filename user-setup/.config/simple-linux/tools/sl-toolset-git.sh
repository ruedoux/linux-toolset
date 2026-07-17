#!/bin/bash

export TOOLSET_SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
. "${TOOLSET_SCRIPT_DIR}/global.sh"

switch_account() {
  local account_name="$1"
  local account_dir="$2"
  local account_file="$account_dir/$account_name"

  if [ ! -f "$account_file" ]; then
    error "Account profile '$account_name' not found in $account_dir"
    return 1
  fi

  unset SSH_KEY USER_NAME USER_EMAIL
  . "$account_file"

  if [ -z "$SSH_KEY" ] || [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ]; then
    error "Account profile must define SSH_KEY, USER_NAME, and USER_EMAIL"
    return 1
  fi

  local ssh_agent_pid="$(pgrep -u "$USER" ssh-agent)"
  if [ -n "$ssh_agent_pid" ]; then
    kill -9 "$ssh_agent_pid"
    info "[git] Killed ssh-agent: $ssh_agent_pid"
  fi

  eval "$(ssh-agent -s)" >/dev/null
  ssh-add "$SSH_KEY" 
  info "[git] Switched to $account_name account"
  git config --global user.name "$USER_NAME"
  git config --global user.email "$USER_EMAIL"
}

main() {
  local account_name=""
  local account_dir=$HOME/.config/git-accounts
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--account)
        account_name="$2"
        shift 2
        ;;
      -d|--dir)
        account_dir="$2"
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

  if [[ -z "$account_name" || -z "$account_dir" ]]; then
    error "Usage: . $SCRIPT_NAME --account <name> --dir <directory>"
    return 1
  fi

  switch_account "$account_name" "$account_dir"
}

main "$@"
