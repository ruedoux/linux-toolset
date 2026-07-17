#!/bin/sh
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

emit() {
  title=$(hyprctl activewindow -j | jq -r '.title // empty')
  echo "$title"
}

emit

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
  case "$line" in
    activewindow\>\>*|closewindow\>\>*|focusedmon\>\>*|workspace\>\>*|windowtitle*)
      emit ;;
  esac
done
