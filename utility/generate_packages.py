import json
import os
import shutil
import subprocess

def check_dependency(dependency):
    if shutil.which(dependency):
        return True
    print(f"{dependency} not installed.")
    return False

script_dir = os.path.dirname(os.path.realpath(__file__))

# loading versions information from json
version_info_path = os.path.join(script_dir, "version_info.json")
with open(version_info_path, "r") as f:
    version_info = json.load(f)

# Arch
def generate_arch():
    pkgbuild_template = os.path.join(script_dir, "../templates/PKGBUILD")
    pkgbuild_path = os.path.join(script_dir, "../PKGBUILD")

    with open(pkgbuild_template, "r") as f:
        pkgbuild = f.read()

    pkgbuild = pkgbuild.replace("%version%", version_info["ym"]["version"])
    pkgbuild = pkgbuild.replace("%release%", "1")
    pkgbuild = pkgbuild.replace("%exe_name%", version_info["ym"]["exe_name"])
    pkgbuild = pkgbuild.replace("%exe_link%", version_info["ym"]["exe_link"])
    pkgbuild = pkgbuild.replace("%exe_sha256%", version_info["ym"]["exe_sha256"])

    with open(pkgbuild_path, "w") as f:
        f.write(pkgbuild)


# Nix
    
def is_nix_version_2_19():
    version = subprocess.run(["nix", "--version"], capture_output=True, text=True).stdout.split()[2]
    print(f"Nix version: {version}")
    major, minor, _ = map(int, version.split("."))
    if major > 2 or (minor >= 19 and major == 2):
        return True
    return False

def generate_nix():
    nixcmd = "nix --extra-experimental-features nix-command --extra-experimental-features flakes"
    flake_path = os.path.join(script_dir, "../flake.nix")

    # Update url in flake.nix
    with open(flake_path, "r") as f:
        flake = f.read()
    _start_index = flake.find("ymExe.url = ")
    _end_index = flake.find(";", _start_index)
    flake = flake.replace(flake[_start_index:_end_index+1], f'ymExe.url = "{version_info["ym"]["exe_link"]}";')
    with open(flake_path, "w") as f:
        f.write(flake)

    if not check_dependency("nix"):
        print("flake.nix was updated, but nix is not installed to update flake.lock")
        return
    
    if is_nix_version_2_19():
        subprocess.run(f"{nixcmd} flake update ymExe", shell=True)
    else:
        subprocess.run(f"{nixcmd} flake lock --update-input ymExe", shell=True)

    if subprocess.run("git status --porcelain -- flake.lock", shell=True).stdout:
        subprocess.run(f"{nixcmd} flake update", shell=True)


generate_arch()
generate_nix()