import subprocess
import requests

from io import BytesIO
from PIL import Image

CACHE: dict[str, str] = {}

_: subprocess.CompletedProcess = subprocess.run(
    ["playerctl", "--ignore-player", "firefox" ,"metadata"],
    capture_output = True,
    text = True
)
if _.returncode != 0:
    print(
        " No media found",
        flush = True
    )

proc: subprocess.Popen = subprocess.Popen(
    ["playerctl", "--ignore-player", "firefox", "-F", "metadata", "-f", "{{mpris:artUrl}}|{{album}}|{{artist}}|{{title}}"],
    stdout = subprocess.PIPE,
    stderr = subprocess.DEVNULL,
    text = True
)

for line in proc.stdout:    # type: ignore
    line: str = line.strip()
    if not line:
        print(
            " No media found",
            flush = True
        ); continue
    
    parts: list[str] = line.split("|")
    artUrl: str = parts[0].strip()
    album: str = parts[1].strip()
    artist: str = parts[2].strip()
    title: str = "|".join(parts[3:]).strip()

    color: str = "#eceff4"
    data = None
    if artUrl:
        if artUrl in CACHE:
            color = CACHE[artUrl]
        elif artUrl.startswith("file://"):
            data = artUrl.removeprefix("file://")
        else:
            try:
                data = BytesIO(requests.get(
                    artUrl,
                    timeout = 20
                ).content)
            except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
                pass
        if data:
            with Image.open(data) as img:
                dominant: tuple[int, int, int] = img.resize((1, 1)).getpixel((0, 0))    # type: ignore
            color = f"#{dominant[0]:02x}{dominant[1]:02x}{dominant[2]:02x}"
            CACHE[artUrl] = color

    print(
        f"%{{F{color}}}%{{F#eceff4}} {title}{f' ({album})' if album and album != title else ''} - {artist}",
        flush = True
    )

"""
old ver, ignore it

for line in proc.stdout:    # type: ignore
    line = line.strip()
    if not line:
        print(
            " No media found",
            flush = True
        )
    else:
        color: str = "#eceff4"
        FORE: str = color
        parts: list[str] = line.split("|")
        artUrl: str = parts[-1].strip()
        if artUrl:
            if artUrl in CACHE:
                color = CACHE[artUrl]
            else:
                if artUrl.startswith("file://"):
                    dom = Image.open(artUrl[7:]).resize((1, 1)).getpixel((0, 0))
                else:
                    try:
                        dom = Image.open(BytesIO(requests.get(
                            artUrl,
                            timeout = 30
                        ).content)).resize((1, 1)).getpixel((0, 0))
                    except (requests.exceptions.Timeout):
                        pass
                color = f"#{dom[0]:02x}{dom[1]:02x}{dom[2]:02x}"    # type: ignore
                CACHE[artUrl] = color
        print(
            f"%{{F{color}}}%{{F{FORE}}} {parts[0].strip()}",
            flush = True
        )
"""
