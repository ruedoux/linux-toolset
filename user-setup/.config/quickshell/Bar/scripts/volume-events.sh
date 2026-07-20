#!/bin/sh
# PipeWire-native volume monitor — zero pactl/PA connections
# wpctl talks to WirePlumber via D-Bus, pw-mon monitors PipeWire directly

emit_vol() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed -n 's/.*: \([0-9.]\+\).*/\1/p'
}

emit_vol

pw-mon | while read -r line; do
  case "$line" in
    *"changed"*) emit_vol ;;
  esac
done
