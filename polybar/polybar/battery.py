import pydbus
from gi.repository import GLib    # type: ignore

system_bus = pydbus.SystemBus()
loop = GLib.MainLoop()

def update() -> None:
    battery_state = ""
    bluetooth_state = "%{F#eceff4}"
    with open("/sys/class/power_supply/AC/online", "r") as fb:
        if fb.read().strip() == "1":
            battery_state = ""
        else:
            battery_state = ""
    manager = system_bus.get(
        "org.bluez",
        "/"
    )
    objects = manager.GetManagedObjects()
    for _, interfaces in objects.items():
        device = interfaces.get("org.bluez.Device1")
        if not device:
            continue
        if device.get("Connected"):
            bluetooth_state = "%{F#5e81ac}"
            break
    print(
        f"{battery_state} {bluetooth_state}",
        flush = True
    )

update()
system_bus.subscribe(
    iface="org.freedesktop.DBus.Properties",
    signal="PropertiesChanged",
    signal_fired=lambda *_: update(),
)

system_bus.subscribe(
    iface="org.freedesktop.UPower",
    signal="Changed",
    signal_fired=lambda *_: update(),
)
loop.run()
