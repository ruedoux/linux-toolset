#!/bin/bash

set -e

remind() {
  local RED_COLOR='\033[0;31m'
  local NO_COLOR='\033[0m'

  local last_reminder_file="$1"
  local remind_seconds="$2"
  local reminder_content="$3"
  
  if ! [[ "$remind_seconds" =~ ^[0-9]+$ ]] || [ "$remind_seconds" -le 0 ]; then
    echo "Error: seconds must be a positive integer"
    exit 1
  fi

  local seconds_epoch=$(date +%s)
  if [ ! -f "$last_reminder_file" ]; then
    echo $seconds_epoch > $last_reminder_file
    echo "Reminder will trigger every $remind_seconds seconds"
  fi

  local last_reminder_epoch=$(cat "$last_reminder_file")
  if [ $((seconds_epoch - last_reminder_epoch)) -ge $remind_seconds ]; then
    echo -e "${RED_COLOR}[REMINDER]${NO_COLOR} $reminder_content"
    echo -e "[INFO] When done delete this file and message will disappear: $last_reminder_file"
  fi
}

main() {
  local SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
  local last_reminder_file=""
  local remind_seconds=""
  local reminder_content=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--file)
        last_reminder_file="$2"
        shift 2
        ;;
      -s|--seconds)
        remind_seconds="$2"
        shift 2
        ;;
      -c|--content)
        reminder_content="$2"
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

  if [[ -z "$last_reminder_file" || -z "$remind_seconds" || -z "$reminder_content" ]]; then
    echo "Usage: . $SCRIPT_NAME --file <file> --seconds <seconds> --content <content>"
    return 1
  fi

  remind "$last_reminder_file" "$remind_seconds" "$reminder_content"
}

main "$@"
