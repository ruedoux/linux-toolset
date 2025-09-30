#!/bin/bash
set -e

RED_COLOR='\033[0;31m'
BLUE_COLOR='\033[0;34m'
PURPLE_COLOR='\033[0;35m'
NO_COLOR='\033[0m'

info() {
  echo -e "${BLUE_COLOR}[INFO]${NO_COLOR} $@"
}

error() {
  echo -e "${RED_COLOR}[ERROR]${NO_COLOR} $@"
}

debug() {
  if [[ -n "$TOOLSET_DEBUG" ]]; then
    echo -e "${PURPLE_COLOR}[DEBUG]${NO_COLOR} $@"
  fi
}

get_json_value() {
  local config_file_path="$1"
  local key="$2"
  local value=$(jq -er ".\"$key\"" "$config_file_path") || {
    error "'$key' is a required key in config file '$config_file_path'"
    exit 1
  }
  echo "$value"
}

ensure_file_exists() {
  local file_path=$1

  if ! [ -f $file_path ]; then
    error "File does not exist or is not accessible: '$file_path'"
    exit 1
  fi
}

ensure_repo_exists() {
  local repo_path="$1"

  if ! [[ -f "$repo_path/config" ]]; then
    read -p "No restic repo found at $repo_path. Create new repo there? [Y/n] " answer
    answer=${answer:-Y}

    if [[ "$answer" =~ ^[Yy]$ ]]; then
      restic init --repo "$repo_path"
    else
      echo "Aborted."
      exit 1
    fi
  fi
}

test_connection() {
  local server_name="$1"

  info "Testing connection to server: '$server_name'"
  if ssh -o BatchMode=yes -o ConnectTimeout=5 $server_name exit 2>/dev/null; then
    info "Connection to server: '$server_name' successful"
  else
    error "Connection to server: '$server_name' failed"
    exit 1
  fi
}

rsync_copy() {
  local rsync_source=$1
  local rsync_destination=$2
  info "Copying '$rsync_source' to '$rsync_destination' with checksum"
  rsync -arzP --delete --checksum $rsync_source $rsync_destination
}

backup() {
  local config_file_path="$1"

  ensure_file_exists $config_file_path
  local repo_root=$(get_json_value $config_file_path "repo-root")
  local repo_name=$(get_json_value $config_file_path "repo-name")
  local repo_path="${repo_root}/${repo_name}"

  local includes_file=$(mktemp)
  local excludes_file=$(mktemp)

  jq -r '.includes[]' "$config_file_path" > "$includes_file"
  jq -r '.excludes[]' "$config_file_path" > "$excludes_file"

  debug "Includes content:\n$(cat "$includes_file")"
  debug "Excludes content:\n$(cat "$excludes_file")"
  ensure_repo_exists $repo_path

  info "Running backup to '$repo_path'"

  if ! [[ -n "$RESTIC_PASSWORD" ]]; then
    if jq -e "has(\"key\")" "$config_file_path" > /dev/null; then
      export RESTIC_PASSWORD=$(jq -r '.["key"]' $config_file_path)
    else
      read -s -p "Enter repository password: " RESTIC_PASSWORD
      export RESTIC_PASSWORD
    fi
  fi

  restic -r $repo_path backup \
    --files-from $includes_file \
    --iexclude-file $excludes_file \
    --tag main \
    --compression max \
    --exclude-caches

  prune_params=$(jq -r '.["restic-forget-params"] | join(" ")' $config_file_path)
  info "Pruning repo '$repo_path'"
  restic -r $repo_path forget --prune --quiet $prune_params
  info "Finished backing up to '$repo_path'"

  info "Listing snapshots for '$repo_path'"
  restic -r $repo_path snapshots

  info "Showing backups size"
  du --max-depth 1 -h $repo_root

  rm $includes_file
  rm $excludes_file
  export RESTIC_PASSWORD=""
}

backup_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local config_file_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--config)
        config_file_path="$2"
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

  if [[ -z "$config_file_path" ]]; then
      echo "Usage: $SCRIPT_NAME backup --config <file>"
      return 1
  fi

  backup "$config_file_path"
}

remote_backup() {
  local config_file_path="$1"

  ensure_file_exists $config_file_path
  local server_name=$(get_json_value $config_file_path "server")

  test_connection $server_name

  local script_name="$(basename "${BASH_SOURCE[0]:-$0}")"
  local script_destination_path="/tmp/$script_name"
  rsync_copy $0 $server_name:$script_destination_path

  local config_destination_path="/tmp/config.json"
  rsync_copy $config_file_path $server_name:$config_destination_path

  info "Running backup on server '$server_name'"
  ssh -t $server_name "${script_destination_path} backup --config ${config_destination_path}"

  info "Shreding sent config file"
  ssh $server_name shred $config_destination_path
}

remote_backup_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local config_file_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--config)
        config_file_path="$2"
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

  if [[ -z "$config_file_path" ]]; then
      echo "Usage: $SCRIPT_NAME remote-backup --config <file>"
      return 1
  fi

  remote_backup "$config_file_path"
}

push_backup() {
  local local_config_file_path="$1"
  local destination_config_file_path="$2"
  local push_repo_name="$3"

  ensure_file_exists $local_config_file_path
  ensure_file_exists $destination_config_file_path

  local local_repo_root=$(get_json_value $local_config_file_path "repo-root")
  local destination_repo_root=$(get_json_value $destination_config_file_path "repo-root")
  local server_name=$(get_json_value $destination_config_file_path "server")
  local push_repo_path="$local_repo_root/$push_repo_name"

  info "Pushing local repository '$push_repo_name' to server '$server_name'"
  if ! [[ -f "$push_repo_path/config" ]]; then
    error "Provided repo doesnt exist or isn't accessible: '$push_repo_path'"
    exit 1
  fi

  test_connection $server_name
  rsync_copy $push_repo_path/ $server_name:$destination_repo_root/$push_repo_name
  info "Finished pushing '$push_repo_name' to server '$server_name'"

  info "Showing destination repository sizes"
  ssh -t $server_name du --max-depth 1 -h $destination_repo_root
}

push_backup_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local local_config_file_path=""
  local destination_config_file_path=""
  local repo_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -lc|--local-config)
        local_config_file_path="$2"
        shift 2
        ;;
      -dc|--destination-config)
        destination_config_file_path="$2"
        shift 2
        ;;
      -r|--repo)
        repo_name="$2"
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

  if [[ -z "$local_config_file_path" || -z "$destination_config_file_path" || -z "$repo_name" ]]; then
      echo "Usage: $SCRIPT_NAME push-backup --local-config <file> --destination-config <file> --repo <name>"
      return 1
  fi

  push_backup $local_config_file_path $destination_config_file_path $repo_name
}

pull_backup() {
  local local_config_file_path="$1"
  local destination_config_file_path="$2"
  local pull_repo_name="$3"

  ensure_file_exists $local_config_file_path
  ensure_file_exists $destination_config_file_path

  local local_repo_root=$(get_json_value $local_config_file_path "repo-root")
  local destination_repo_root=$(get_json_value $destination_config_file_path "repo-root")
  local server_name=$(get_json_value $destination_config_file_path "server")
  local pull_repo_path="$destination_repo_root/$pull_repo_name"

  info "Pulling remote repository '$pull_repo_name' from server '$server_name'"
  test_connection $server_name
  if ! ssh $server_name "[[ -f '$pull_repo_path/config' ]]"; then
    error "Provided repo doesn't exist or isn't accessible: '$server_name:$pull_repo_path'"
    exit 1
  fi

  rsync_copy $server_name:$pull_repo_path/ $local_repo_root/$pull_repo_name
  info "Finished pulling '$pull_repo_name' to server '$server_name'"

  info "Showing destination repository sizes"
  du --max-depth 1 -h $local_repo_root
}

pull_backup_entry() {
  SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local local_config_file_path=""
  local destination_config_file_path=""
  local repo_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -lc|--local-config)
        local_config_file_path="$2"
        shift 2
        ;;
      -dc|--destination-config)
        destination_config_file_path="$2"
        shift 2
        ;;
      -r|--repo)
        repo_name="$2"
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

  if [[ -z "$local_config_file_path" || -z "$destination_config_file_path" || -z "$repo_name" ]]; then
      echo "Usage: $SCRIPT_NAME pull-backup --local-config <file> --destination-config <file> --repo <name>"
      return 1
  fi

  pull_backup $local_config_file_path $destination_config_file_path $repo_name
}

case "$1" in
  backup)
    shift
    backup_entry "$@"
    ;;
  remote-backup)
    shift
    remote_backup_entry "$@"
    ;;
  push-backup)
    shift
    push_backup_entry "$@"
    ;;
  pull-backup)
    shift
    pull_backup_entry "$@"
    ;;
  *)
    SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
    echo "Usage: $SCRIPT_NAME [backup|remote-backup|push_backup|pull-backup]"
    exit 1
    ;;
esac