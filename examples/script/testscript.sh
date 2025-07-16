#!/usr/bin/env sh

case "$1" in
  "")
    printf 'foo\nnon existing command'
    ;;
  "foo")
    echo "bar"
    ;;
  "bar")
    # final command selected, perform some action
    exit 0
    ;;
  *)
    echo "Invalid argument: $1" >&2
    echo "Usage: $0 <foo|bar>" >&2
    exit 1
esac
