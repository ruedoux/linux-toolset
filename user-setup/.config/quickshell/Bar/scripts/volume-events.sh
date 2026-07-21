#!/bin/sh
emit_vol() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | sed -n 's/.*: \([0-9.]\+\).*/\1/p'
}

emit_vol

while sleep 0.5; do
  emit_vol
done
