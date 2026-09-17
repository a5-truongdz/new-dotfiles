import time
import os

for dir in os.listdir("/sys/class/hwmon/"):
    with open(f"/sys/class/hwmon/{dir}/name", "r") as f:
        if f.read().strip() == "coretemp":
            HWMON: str = dir

def update() -> None:
    with open(
        f"/sys/class/hwmon/{HWMON}/temp2_input",
        "r"
    ) as fb:
        temp1 = int(fb.read().strip())
    with open(
        f"/sys/class/hwmon/{HWMON}/temp4_input",
        "r"
    ) as fb:
        temp2 = int(fb.read().strip())
    temp = (temp1 + temp2) / 2 / 1000
    icons = ""
    if temp >= 90:
        icons = ""
    print(
        f"{icons}{'%{F#bf616a}' if temp >= 90 else ''}{temp}°C",
        flush=True
    )

while True:
    update()
    time.sleep(1)
