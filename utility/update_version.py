import atexit
import hashlib
import json
import os
import shutil
import tempfile
import requests

YM_VERSIONS_URL = "https://music-desktop-application.s3.yandex.net/stable/download.json"
ELECTRON_VERSIONS_URL = "https://releases.electronjs.org/releases.json"
ELECTRON_DOWNLOAD_URL = "https://github.com/electron/electron/releases/download/v{0}/electron-v{0}-linux-{1}.zip"

script_dir = os.path.dirname(os.path.realpath(__file__))
tempdir = tempfile.mkdtemp()

def clear():
    shutil.rmtree(tempdir)

atexit.register(clear)

def assert_dependency(dependency):
    if shutil.which(dependency):
        return
    print(f"{dependency} not installed.")
    exit(1)

# loading versions json
versions_obj = requests.get(YM_VERSIONS_URL).json()
exe_link = versions_obj["windows"]
version = exe_link.split("x64_")[1].split(".exe")[0]
exe_name = os.path.basename(exe_link)

# downloading exe file
print(f"Downloading {exe_name}")
exe_path = os.path.join(tempdir, exe_name)
with open(exe_path, "wb") as f:
    f.write(requests.get(exe_link).content)

# calculating sha256
print("Calculating sha256")
with open(exe_path, "rb") as f:
    exe_sha256 = hashlib.sha256(f.read()).hexdigest()
print(f"Sha256: {exe_sha256}")

# getting electron version
print("Getting latest electron version")
electron_releases = requests.get(ELECTRON_VERSIONS_URL).json()
electron_versions = list(map(lambda x: x["version"], electron_releases))
electron_versions = list(filter(lambda x: "-" not in x and x.startswith("27"), electron_versions))
electron_version = electron_versions[0]
print(f"Latest electron version: {electron_version}")
electron_x64 = ELECTRON_DOWNLOAD_URL.format(electron_version, "x64")
electron_armv7l = ELECTRON_DOWNLOAD_URL.format(electron_version, "armv7l")
electron_arm64 = ELECTRON_DOWNLOAD_URL.format(electron_version, "arm64")

version_info = {
    "ym": {
        "version": version,
        "exe_name": exe_name,
        "exe_link": exe_link,
        "exe_sha256": exe_sha256
    },
    "electron": {
        "version": electron_version,
        "x64": electron_x64,
        "armv7l": electron_armv7l,
        "arm64": electron_arm64
    }
}

version_file = os.path.join(script_dir, "version_info.json")

# writing json to file
with open(version_file, "w") as f:
    f.write(json.dumps(version_info, indent=4))

print(f"Version info written to {version_file}")