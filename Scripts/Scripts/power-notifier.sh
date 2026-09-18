#!/bin/bash

last=""

upower --monitor | while read -r line; do
    [[ "$line" == *"line_power_AC"* ]] || continue

    current=$(
        upower -i /org/freedesktop/UPower/devices/line_power_AC |
        awk '/online:/ {print $2}'
    )

    [[ "$current" == "$last" ]] && continue
    last="$current"

    if [[ "$current" == "yes" ]]; then
        notify-send "Power" "Charger plugged in"
    else
        notify-send -i dialog-warning "Power" "Charger unplugged"
    fi
done
