#!/usr/bin/env sh

rofi \
  -show-icons \
  -icon-theme "Tela circle nord dark" \
  -modi "drun,power:$HOME/.local/bin/power.sh,run:$HOME/.local/bin/run.sh,media:$HOME/.local/bin/media.sh" \
  -show drun \
  -drun-display-format "{name} <span alpha='70%' size='small'><i>{generic}</i></span>
<span alpha='70%' size='small'>{exec}</span>" \
  -sorting-method fzf
