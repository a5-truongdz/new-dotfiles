from colorama import *
from typing import *
from itertools import zip_longest

class Disk(TypedDict):
    name: str
    used: float
    total: float
    free: float
    perc: int
    used_unit: str
    total_unit: str
    free_unit: str

class PythonFetch:
    def __init__(
        self,
        username: str,
        hostname: str,
        distro_name: str,
        architecture: str,
        distro_version: str,
        kernel: str,
        kernel_version: str,
        disk: list[Disk],
        virt: list[Disk],
        uptime: tuple[int, int],
        music: tuple[str, str, str, str],
        quote: str
    ) -> None:
        self.username: str = username
        self.hostname: str = hostname
        self.distro_name: str = distro_name
        self.architecture: str = architecture
        self.distro_version: str = distro_version
        self.kernel: str = kernel
        self.kernel_version: str = kernel_version
        self.disk: list[Disk] = disk
        self.virt: list[Disk] = virt
        self.uptime: tuple[int, int] = uptime
        self.music: tuple[str, str, str, str] = music
        self.quote: str = quote

    def color(self, icon: str, text: str) -> str:
        return f"{Style.BRIGHT}{Fore.YELLOW}{icon}{Style.RESET_ALL} {text}{Style.RESET_ALL}\n"

    def text(self) -> str:
        info: str = ""
        max_name: int = -1
        max_used: int = -1
        max_total: int = -1
        max_free: int = -1
        max_perc: int = -1
        bright_cyan: str = f"{Style.BRIGHT}{Fore.CYAN}"
        bright_yellow: str = f"{Style.BRIGHT}{Fore.YELLOW}"
        info += self.color("", f"{bright_cyan}{self.username}{Style.RESET_ALL}@{bright_cyan}{self.hostname}")
        info += self.color("", f"{self.distro_name} {self.architecture} ({bright_yellow}{self.distro_version}{Style.RESET_ALL})")
        info += self.color("󰍛", f"{self.kernel} {self.kernel_version}")
        for disk in self.disk:
            max_name = max(max_name, len(disk["name"]))
            max_used = max(max_used, len(str(disk["used"])))
            max_total = max(max_total, len(str(disk["total"])))
            max_free = max(max_free, len(str(disk["free"])))
            max_perc = max(max_perc, len(str(disk["perc"])))
        for disk in self.virt:
            max_name = max(max_name, len(disk["name"]))
            max_used = max(max_used, len(str(disk["used"])))
            max_total = max(max_total, len(str(disk["total"])))
            max_free = max(max_free, len(str(disk["free"])))
            max_perc = max(max_perc, len(str(disk["perc"])))
        for disk in self.disk:
            info += self.color("", f"{bright_cyan}{disk['name']}{' ' * (max_name - len(disk['name']))}{Style.RESET_ALL}: {' ' * (max_used - len(str(disk['used'])))}{disk['used']}{disk['used_unit']} / {disk['total']}{' ' * (max_total - len(str(disk['total'])))}{disk['total_unit']} ({bright_yellow}{disk['free']}{' ' * (max_free - len(str(disk['free'])))}{disk['free_unit']}{Style.RESET_ALL} free) - {' ' * (max_perc - len(str(disk['perc'])))}{disk['perc']}%")
        for disk in self.virt:
            info += self.color("", f"{bright_cyan}{disk['name']}{' ' * (max_name - len(disk['name']))}{Style.RESET_ALL}: {' ' * (max_used - len(str(disk['used'])))}{disk['used']}{disk['used_unit']} / {disk['total']}{' ' * (max_total - len(str(disk['total'])))}{disk['total_unit']} ({bright_yellow}{disk['free']}{' ' * (max_free - len(str(disk['free'])))}{disk['free_unit']}{Style.RESET_ALL} free) - {' ' * (max_perc - len(str(disk['perc'])))}{disk['perc']}%")
        info += self.color("", f"{self.uptime[0]} hour{'s' if self.uptime[0] > 1 else ''}, {self.uptime[1]} minute{'s' if self.uptime[1] > 1 else ''}")
        info += self.color("", f"{self.music[0]}: {self.music[1]}{f' ({self.music[2]})' if self.music[2] != '' else ''} - {self.music[3]}")
        info += f'{Style.BRIGHT}"{self.quote}"{Style.RESET_ALL}'
        return info

import getpass
import socket
import distro
import platform
import psutil
from psutil import _common
import uptime
import dbus
import random

def readable(bytes: int) -> tuple[float, str]:
    size: float = float(bytes)
    for unit in [" B", "KB", "MB", "GB", "TB", "PB"]:
        if size < 1024:
            return (float(f"{size:.2f}"), unit)
        size /= 1024
    return (float(f"{size:.2f}"), "EB")

_username: str = getpass.getuser()
_hostname: str = socket.gethostname()
_distro_name: str = distro.name()
_architecture: str = platform.machine()
_distro_version: str = distro.version()
_kernel: str = platform.system()
_kernel_version: str = platform.release()

mountpoints: list[str] = []
with open("/proc/self/mounts", "r") as file:
    for line in file:
        parts: list[str] = line.strip().split()
        if parts[0].strip().startswith("/dev"):
            mountpoints.append(parts[1].strip())

_disk: list[Disk] = []
for mountpoint in mountpoints:
    disk_usage: _common.sdiskusage = psutil.disk_usage(mountpoint)
    used: tuple[float, str] = readable(disk_usage.used)
    total: tuple[float, str] = readable(disk_usage.total)
    free: tuple[float, str] = readable(disk_usage.free)
    perc: int = int(disk_usage.percent)
    _disk.append({
        "name": mountpoint,
        "used": used[0],
        "used_unit": used[1],
        "total": total[0],
        "total_unit": total[1],
        "free": free[0],
        "free_unit": free[1],
        "perc": perc
    })

_virt: list[Disk] = []
ram: psutil._pslinux.svmem = psutil.virtual_memory()
used: tuple[float, str] = readable(ram.used)
total: tuple[float, str] = readable(ram.total)
free: tuple[float, str] = readable(ram.available)
perc: int = int(ram.percent)
_virt.append({
    "name":  "RAM",
    "used": used[0],
    "used_unit": used[1],
    "total": total[0],
    "total_unit": total[1],
    "free": free[0],
    "free_unit": free[1],
    "perc": perc
})

with open("/proc/swaps") as file:
    next(file)
    for line in file:
        parts: list[str] = line.strip().split()
        used: tuple[float, str] = readable(int(parts[3]) * 1000)
        total: tuple[float, str] = readable(int(parts[2]) * 1000)
        free: tuple[float, str] = readable(int(parts[2]) * 1000 - int(parts[3]) * 1000)
        perc: int = int(int(parts[3]) * 1000 / (int(parts[2]) * 1000) * 100)
        _virt.append({
            "name": f"Swap: {parts[0].strip()}",
            "used": used[0],
            "used_unit": used[1],
            "total": total[0],
            "total_unit": total[1],
            "free": free[0],
            "free_unit": free[1],
            "perc": perc,
        })

up: float = cast(float, uptime.uptime())
hr: tuple[int, int] = divmod(int(up), 3600)
hours = hr[0]
mins: int = divmod(hr[1], 60)[0]
_uptime: tuple[int, int] = (hours, mins)

sessionBus: dbus.SessionBus = dbus.SessionBus()
names: list[str] = cast(list[str], sessionBus.list_names())
if "org.mpris.MediaPlayer2.spotify" not in names:
    playbackStatus: str = "Stopped"
    title: str = ""
    album: str = ""
    artists: str = ""
else:
    interface: dbus.Interface = dbus.Interface(sessionBus.get_object("org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2"), "org.freedesktop.DBus.Properties")
    metadata: dict[str, Any] = interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")
    playbackStatus: str = interface.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus")
    title: str = metadata["xesam:title"]
    album: str = metadata["xesam:album"]
    artists: str = ", ".join(metadata["xesam:artist"])
_music: tuple[str, str, str, str] = (playbackStatus, title, album, artists)

with open("/home/tr43212/Scripts/excuses.txt", "r") as file:
    _quote: str = random.choice(file.readlines()).strip()

pf: PythonFetch = PythonFetch(
    _username,
    _hostname,
    _distro_name,
    _architecture,
    _distro_version,
    _kernel,
    _kernel_version,
    _disk,
    _virt,
    _uptime,
    _music,
    _quote
)

ascii_art = r"""
      /\
     /  \
    /    \
   /      \
  /   ,,   \
 /   |  |   \
/_-''    ''-_\
""".splitlines()
info = pf.text().splitlines()

ascii_width = max(len(line) for line in ascii_art) + 4
for a, b in zip_longest(ascii_art, info[:-1], fillvalue=""):
    print(f"{Style.BRIGHT}{Fore.CYAN}{a.ljust(ascii_width)}{Style.RESET_ALL}{b}", flush=True)
print(info[-1], flush=True)
