#!/bin/sh

# This script generates tmux source-file commands for all scripts in the
# specified directory.

find "$HOME/.tmux/scripts" -type f  | while read -r i; do
  echo "tmux source-file $i"
done
