#!/bin/sh

if [ $# -eq 0 ] || [ "$1" = "" ]; then
  nmcli -f active,name connection show | awk 'BEGIN { FS="  +" } NR > 1 {
    if ($1 == "no") {
      printf("up %s\n", $2)
    } else {
      printf("down %s\n", $2)
    }
  }'
  exit 0
fi

cmd="$(echo "$1" | cut -d ' ' -f 1)"
network="$(echo "$1" | cut -d ' ' -f 2-)"

if [ "$cmd" = "up" ]; then
  nmcli connection up "$network" > /dev/null
elif [ "$cmd" = "down" ]; then
  nmcli connection down "$network" > /dev/null
else
  echo "Usage: $0 <up|down> <network>"
  exit 1
fi
