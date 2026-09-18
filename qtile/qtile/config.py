import os
import subprocess

import libqtile.resources
from libqtile import layout, qtile, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

# Keys
mod = "mod4"
alt = "mod1"

# Binaries
terminal = "konsole"
rofi = os.path.expanduser("~/Scripts/rofi.sh")

# Colors
polar_night = "#2e3440"
disabled = "#4c566a"
snow_storm = "#eceff4"
frost = "#5e81ac"
red = "#bf616a"
transparent = "#00000000"

# Keymaps
keys = [
    # Mod+LRUD: Change focus
    Key([mod], "left", lazy.layout.left()),
    Key([mod], "right", lazy.layout.right()),
    Key([mod], "up", lazy.layout.up()),
    Key([mod], "down", lazy.layout.down()),

    # Mod+Alt+LRUD: Move windows
    Key([mod, alt], "left", lazy.layout.shuffle_left()),
    Key([mod, alt], "right", lazy.layout.shuffle_right()),
    Key([mod, alt], "up", lazy.layout.shuffle_up()),
    Key([mod, alt], "down", lazy.layout.shuffle_down()),

    # Ctrl+Mod+LRUD: "Grow" windows
    Key(["control", mod], "left", lazy.layout.grow_left()),
    Key(["control", mod], "right", lazy.layout.grow_right()),
    Key(["control", mod], "up", lazy.layout.grow_up()),
    Key(["control", mod], "down", lazy.layout.grow_down()),

    # Ctrl+Mod+N: Reset window sizes
    Key(["control", mod], "n", lazy.layout.normalize()),

    # Ctrl+Alt+T: Launch terminal
    Key(["control", alt], "t", lazy.spawn(terminal)),

    # Alt+F4: Kill current window
    Key([alt], "F4", lazy.window.kill()),

    # Mod+F: Toggle floating
    Key([mod], "f", lazy.window.toggle_floating()),

    # Ctrl+Mod+R: Reload the config
    Key(["control", mod], "r", lazy.reload_config()),

    # Ctrl+Space: Launch rofi
    Key(["control"], "space", lazy.spawn(rofi, shell=True)),

    # Mod+L: Lock the screen
    Key([mod], "l", lazy.spawn("betterlockscreen -l blur --off 300")),

    # Fn+F2,3: Brightness control
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set 10%+")),

    # Fn+F7,8,9: Volume control
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),

    # Fn+F10,11,12: Music control
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
]

# Groups
group_name = ["I", "II", "III", "IV", "V"]
groups = [Group(i) for i in group_name]

for i, name in enumerate(group_name):
    idx = str(i + 1)

    # Keymaps for groups
    keys.extend([
        # Mod+12345: Switch to groups
        Key([mod], idx, lazy.group[name].toscreen()),

        # Mod+Alt+12345: Move window to groups
        Key([mod, alt], idx, lazy.window.togroup(name))
    ])

# Layout
layouts = [
    layout.Bsp(
        border_width=2,
        margin=10,
        border_focus=frost,
        border_normal=polar_night,
        border_on_single=True
    )
]

# Screen
screens = [
    Screen(
        background=transparent,
        wallpaper="~/Documents/wallpaper.jpeg",
        wallpaper_mode="stretch"
    )
]

# Mouse keymap
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod, alt], "Button1", lazy.window.set_size_floating(), start=lazy.window.get_size()),
]

# Floating rules
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="geometrydash.exe"),
        Match(wm_class="oneko")
    ],
    border_width=2,
    border_focus=frost,
    border_normal=polar_night
)

# Unminimize every window
@lazy.function
def unminimize_all(qtile):
    for win in qtile.current_group.windows:
        if getattr(win, "minimized", False):
            win.toggle_minimize()

keys.extend([
    Key([mod], "u", unminimize_all),
])

# Random settings
bring_front_click = "floating_only"
follow_mouse_focus = True
floats_kept_above = False
cursor_warp = True

# Hooks
lock_file = "/tmp/qtile_lock_restart"

@hook.subscribe.startup
def on_startup():
    if os.path.exists(lock_file):
        subprocess.run([os.path.expanduser("~/.config/qtile/restart.sh")])
    else:
        subprocess.run([os.path.expanduser("~/.config/qtile/autostart.sh")])
        open(lock_file, "w").close()

@hook.subscribe.shutdown
def on_shutdown():
    if os.path.exists(lock_file):
        os.remove(lock_file)
