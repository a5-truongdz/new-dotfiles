#!/bin/bash

ID=$(xinput list | grep -i "touchpad" | grep -o 'id=[0-9]*' | cut -d= -f2)
if [ -z "$ID" ]; then
    ID=$(xinput list | grep -i "synaptics" | grep -o 'id=[0-9]*' | cut -d= -f2)
fi
STATUS=$(xinput list-props "$ID" | grep "Device Enabled" | grep -o '[0-1]$')

if [ "$STATUS" -eq 1 ]; then
    xinput disable "$ID"
    notify-send "Touchpad" "Touchpad turned off" -i input-touchpad
else
    xinput enable "$ID"
    notify-send "Touchpad" "Touchpad turned on" -i input-touchpad
fi
