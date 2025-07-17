#!/usr/bin/env sh

# This script can be used with dmenu_run2 as a source for generating aliases
# for NetworkManager connections.

nmcli -f active,name connection show | awk 'BEGIN { FS="  +" } NR > 1 {
  if ($1 == "no") {
    printf("alias %s up=nmcli connection up \"%s\"\n", $2, $2)
  } else {
    printf("alias %s down=nmcli connection down \"%s\"\n", $2, $2)
  }
}'
