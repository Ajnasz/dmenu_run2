#!/bin/sh

# This script generates bluetoothctl commands for all paired devices.

bluetoothctl devices Paired | awk '{print "btconn " $3" "$2}'
