#!/bin/sh
read_stat() {
  line=$(head -1 /proc/stat)
  set -- $line
  total=$((${2}+${3}+${4}+${5}+${6}+${7}+${8}))
  idle=$((${5}+${6}))
  echo "$total $idle"
}

sample1=$(read_stat)
sleep 1
sample2=$(read_stat)

total1=$(echo "$sample1" | cut -d' ' -f1)
idle1=$(echo "$sample1"  | cut -d' ' -f2)
total2=$(echo "$sample2" | cut -d' ' -f1)
idle2=$(echo "$sample2"  | cut -d' ' -f2)

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

if [ "$total_diff" -gt 0 ]; then
  usage=$(( 100 * (total_diff - idle_diff) / total_diff ))
else
  usage=0
fi

printf "%-3d\n" "$usage"
