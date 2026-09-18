import subprocess

PLAY = ""
PAUSE = ""

_ = subprocess.run(
    ["playerctl", "--ignore-player", "firefox","status"],
    capture_output = True,
    text = True
)
if _.returncode != 0:
    print(
        PLAY,
        flush = True
    )



proc: subprocess.Popen = subprocess.Popen(
    ["playerctl", "--ignore-player", "firefox" ,"-F", "status"],
    stdout = subprocess.PIPE,
    stderr = subprocess.DEVNULL,
    text = True
)

for line in proc.stdout:    # type: ignore
    line = line.strip()
    if not line or line == "Paused" or line == "Stopped":
        print(
            PLAY,
            flush = True
        )
    else:
        print(
            PAUSE,
            flush = True
        )
