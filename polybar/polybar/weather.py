import requests
import time
import json

try:
    response = requests.get("https://api.openweathermap.org/data/2.5/forecast?id=1580410&units=metric&appid=309e9cda1f7ed0e2ea3d97cdf9b6d748", timeout = 30)
    with open("./weather.json", "w") as fb:
        fb.write(response.text)
except (requests.exceptions.ConnectionError, requests.exceptions.Timeout):
    pass

with open("./weather.json", "r") as fb:
    data = json.load(fb)

now = time.time()

closest = min(
    data["list"],
    key=lambda x: abs(x["dt"] - now)
)

entry = closest["weather"][0]["icon"]

icons = {
    "01d": "",
    "01n": "",
    "02d": "",
    "02n": "",
    "03d": "",
    "03n": "",
    "04d": "",
    "04n": "",
    "09d": "",
    "09n": "",
    "10d": "",
    "10n": "",
    "11d": "",
    "11n": "",
    "13d": "",
    "13n": "",
    "50d": "",
    "50n": ""
}

print(f"{icons[closest['weather'][0]['icon']]} {float(closest['main']['temp']):.1f}°C")
