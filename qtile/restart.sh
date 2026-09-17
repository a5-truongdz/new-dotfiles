#!/bin/sh

polybar-msg cmd restart &

pkill conky
conky -c ~/.config/conky/clock.conf &
conky -c ~/.config/conky/qtile.conf &
conky -c ~/.config/conky/monitor.conf &
