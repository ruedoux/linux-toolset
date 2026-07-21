#!/bin/sh
while true; do
  connection=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -1)
  if [ -z "$connection" ]; then
    connection="None"
  else
    case "$connection" in
      Wired*) connection="ETH" ;;
      Wi-Fi*|Wireless*) connection="WIFI" ;;
    esac
  fi
  printf "%s\n" "$connection"
  sleep 2
done
