import subprocess

count: int = len(subprocess.run(["checkupdates"], text=True, capture_output=True).stdout.strip().splitlines())

if count == 0:
    print()
else:
    print(f" {count}")
