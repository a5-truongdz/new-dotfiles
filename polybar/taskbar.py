from libqtile.command.client import InteractiveCommandClient
import time

c = InteractiveCommandClient()

def update():
    windows = []

    try:
        focused = c.window.info()["id"]
    except:
        focused = None

    for win in c.windows():
        if win["wm_class"][0] == "polybar":
            continue

        name = win["name"]
        formatted = name[:30] + "..." if len(name) > 30 else name

        # padding lives HERE (and ONLY here)
        formatted = f" {formatted} "

        if win["id"] == focused:
            windows.append(
                f"%{{B#803b4252}}%{{u#5e81ac}}%{{+u}}{formatted}%{{-u}}%{{B-}}"
            )
        else:
            windows.append(formatted)

    if windows:
        sep = "%{F#4c566a}|%{F#eceff4}"
        return sep.join(windows) + "%{F#4c566a}| "
    else:
        return ""

last = ""
while True:
    current = update()
    if current != last:
        print(current, flush=True)
        last = current
    time.sleep(0.2)
