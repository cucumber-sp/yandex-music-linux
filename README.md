# yandex-music-linux

## About
Native YandexMusic client for Linux. Built using repacking of Windows client (Electron app).

## Table of content
- [Screenshots](#screenshots)
- [Installation](#installation)
   - [Arch Linux](#arch-linux)
   - [Debian/Ubuntu](#debianubuntu)
    - [RPM-based](#rpm-based)
- [Configuration](#configuration)
    - [Configuration file](#configuration-file)
    - [Custom Electron binary](#custom-electron-binary)
    - [Electron arguments](#electron-arguments)
    - [Tray mode](#tray-mode)
- [Manual Build](#manual-build)
   - [Prerequisites](#prerequisites)
   - [Extract app only](#extract-app-only)
   - [ASAR archive](#asar-archive)
   - [Arch Linux](#arch-linux-1)
   - [Debian/Ubuntu](#debianubuntu-1)
   - [RPM-based](#rpm-based-1)
- [Run with nix](#run-with-nix)
   - [NixOS unstable](#nixos-unstable)
      - [Run from unstable channel with flakes](#run-from-unstable-channel-with-flakes)
      - [Install from unstable channel](#install-from-unstable-channel)
      - [Overriding](#overriding)
   - [Built-in module](#built-in-module)
      - [Run with flakes](#run-with-flakes)
      - [Run old style](#run-old-style)
      - [Install to NixOS](#install-to-nixos)

## Screenshots
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/ab2f69ee-efc4-4a33-8110-131b4c4ff4de)
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/de618654-15d1-4103-a323-faa00086d0a2)


## Installation

### Arch Linux

#### AUR

You can obtain the latest version of package from `AUR` using one of the [AUR Helpers](https://wiki.archlinux.org/title/AUR_helpers). Then install it with `yandex-music` as package name.

For this example I will use [yay](https://github.com/Jguer/yay)

```bash
yay -S yandex-music
```

#### Binary package file

Download prebuilt binary package from [Releases](https://github.com/cucumber-sp/yandex-music-linux/releases) section.

Then you can install it with the following command

```bash
pacman -U yandex-music-<version>-any.pkg.tar.zst
```

***

### Debian/Ubuntu

#### APT

Download key and add repository to mirror list
```bash
curl -fsSL https://apt.cucumber-space.online/key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/cucumber-space.key.gpg
echo 'deb [signed-by=/etc/apt/keyrings/cucumber-space.key.gpg] https://apt.cucumber-space.online ./' | sudo tee /etc/apt/sources.list.d/cucumber-space.list > /dev/null
sudo apt update
```
Then you can install app with
```bash
sudo apt install yandex-music
```

#### Binary package file

Download prebuilt binary package from [Releases](https://github.com/cucumber-sp/yandex-music-linux/releases) section.

Then you can install it with the following command

```bash
dpkg -i yandex-music_<version>_<arch>.deb
```

***

### RPM-based

#### DNF

Package is currently unavailable at DNF. If you'd like to help us with publishing, feel free to open new issue.

#### Binary package file

Download prebuilt binary package from [Releases](https://github.com/cucumber-sp/yandex-music-linux/releases) section.
Unfortunatelly, we only provide packages for x64 architecture. If you need package for different architecture, you can build it manually.

Then you can install it with the following command

```bash
rpm -i yandex-music-<version>-1.x86_64.rpm
```

***

## Configuration

### Configuration file

You can find configuration file at `HOME/.config/yandex-music.conf`. It's a simple `key=value` file that's sourced before launching the app. This means you can set environment variables and other options there.

***

### Custom Electron binary

You can set path to custom Electron binary with `ELECTRON_CUSTOM_BIN` option. For example:

```bash
ELECTRON_CUSTOM_BIN=/usr/bin/electron
```

***

### Electron arguments

You can set custom Electron flags with `ELECTRON_ARGS` option.  By default it's set to `--no-sandbox`. For example:

```bash
ELECTRON_ARGS="--no-sandbox --trace-warnings"
```

***

### Tray mode

Tray mode is disabled by default. It allows program to be minimized to tray instead of closing. To enable it set `TRAY_ENABLED` option to `1`.

![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/5998ba7f-9ee7-4725-9d51-fbe5510a799d)

***

### Dev tools

Chromium developer/debug tools can be enabled by setting `DEV_TOOLS` option to `1`.

***

## Manual Build

### Prerequisites

That's the list of packages you might need to install to be able to manually build the app. However, you should remember that it might be different for your distro/machine.

```
- nodejs
- npm
- jq
- 7z (p7zip)
- unzip
- python
```

In addition you will need to install [Asar](https://github.com/electron/asar) tool with `npm`. I recommend install it globally with the following command

```bash
npm install -g @electron/asar
```

Last step is to download original client `.exe` file. You can get it yourself or take link to the latest version from `./utility/version_info.json` file.

***

### Extract app only

If you only want to get extracted app project with applied patches, you can use the following command:

```bash
bash repack.sh -x [-o OUTPUT_DIR default=./app] <YM.exe>
```
***

### ASAR archive

`.asar` is archive file that containes all electron app resources and information, but doesn't hold Electron binaries. If you have `.asar` file you can launch app using `electron <app>.asar`. You can build this archive with the following command:

```bash
bash repack.sh [-o OUTPUT_DIR default=./app] <YM.exe>
```

***

### Arch Linux

You can build `pacman` package file manually using `PKGBUILD` file from the this repository. Run following commands in folder with `PKGBUILD` file inside to get `.pkg.tar.zst` package:

```bash
pacman -S electron libpulse
makepkg
```

***

### Debian/Ubuntu

You can build `.deb` binary package using the following command:

```bash
bash build_deb.sh  [-a <x64|armv7l|arm64|all> default=x64]
```

***

### RPM-based

You can build `.rpm` binary package using the following command:

```bash
bash build_rpm.sh  [-a <x64|armv7l|arm64|all> default=x64]
```

## Run with nix

The `yandex-music` package has unlicensed license, so you need to have
`allowUnfree` option enabled.

### NixOS unstable

The `yandex-music` package is
[available](https://github.com/NixOS/nixpkgs/pull/337425) at nixos-unstable
channel.

#### Run from unstable channel with flakes

```bash
nix run github:NixOS/nixpkgs/nixos-unstable#yandex-music
```

#### Install from unstable channel

Add next to your configuration:

```nix
environment.systemPackages = with pkgs; [ yandex-music ];
```

#### Overriding

There is several option of package available to override:

```nix
yandex-music.override {
    trayEnabled = true;     # Whenether to enable tray support
    electronArguments = ""; # Extra arguments to electron executable
}
```

### Built-in module

This repository contains its own nix-related receipts.

#### Run with flakes

Execute next to build and run yandex music directly from github

```bash
nix run github:cucumber-sp/yandex-music-linux
```

#### Run old style

Execute next in this repository to build yandex-music package without using
flakes.

```bash
nix-build --expr '(import <nixpkgs> {}).callPackage ./nix {}'
```

#### Install to NixOS

1. Add input in your flake.nix

    ```nix
    inputs = {
      yandex-music.url = "github:cucumber-sp/yandex-music-linux";
    };
    ```

2. Import module in your `configuration.nix`:
    ```nix
    imports = [
      yandex-music.nixosModules.default
    ];
    ```

    or in `home-manager.nix`:
    ```nix
    imports = [
      yandex-music.homeManagerModules.default
    ];
    ```


3. Enable `yandex-music`

    ```nix
    programs.yandex-music.enable = true;
    programs.yandex-music.tray.enable = true; # to enable tray support
    ```
