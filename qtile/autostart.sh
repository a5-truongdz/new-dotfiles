#!/bin/sh

xrdb -merge ~/.Xresources 

polybar top &
conky -c ~/.config/conky/clock.conf &

nm-applet &
copyq &
dunst &
fcitx5 &
easyeffects -w &
picom &
discord --start-minimized &
xautolock -time 5 -locker "betterlockscreen -l blur --off 300" &
"/opt/Keyboard Sounds/resources/.runtime/kbs" start -p mx-black -m g502x-wireless -c="-2,2" &
~/.venv/bin/volctl &
~/Scripts/power-notifier.sh &

(
    sleep 3
    xmodmap -e "keycode 135 = NoSymbol"

    if [ "$(date +%u)" = 1 ]; then
        notify-send -i system-software-update "Arch Linux" "Remember to update your system!"
    fi
) &
