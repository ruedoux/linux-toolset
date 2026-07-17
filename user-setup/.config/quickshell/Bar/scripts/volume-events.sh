#!/bin/sh
emit() { pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]\+%' | head -1; }

emit

pactl subscribe | while read -r line; do
  case "$line" in
    *"on sink"*|*"on server"*) emit ;;
  esac
done
