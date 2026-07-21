#!/bin/sh
while true; do
  usage=$(free | awk '/^Mem:/ { printf "%d\n", $3/$2 * 100 }')
  printf "%-3d\n" "$usage"
  sleep 1
done
