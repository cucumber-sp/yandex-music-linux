# yandex-music-linux

> **REPOSITORY ARCHIVED**  
> **Yandex has released a native Linux version**   
> This repository used complex Windows executable repacking, which is no longer necessary.
> 
> A new project is being developed to distribute and repackage the official Linux version for Arch Linux, RPM-based distributions, and other package formats.  
> 👀 Stay tuned for updates and the new repository link.
>

## About
Native YandexMusic client for Linux. ~~Built using repacking of Windows client (Electron app).~~


## Screenshots
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/ab2f69ee-efc4-4a33-8110-131b4c4ff4de)
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/de618654-15d1-4103-a323-faa00086d0a2)


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
    - [Always leave to tray](#always-leave-to-tray)
    - [Dev tools](#dev-tools)
    - [Custom title bar](#custom-title-bar)
    - [Vibe animation FPS control](#vibe-animation-fps-control)
- [Manual Build](#manual-build)
   - [Prerequisites](#prerequisites)
   - [Extract app only](#extract-app-only)
   - [ASAR archive](#asar-archive)
   - [Arch Linux](#arch-linux-1)
   - [Debian/Ubuntu](#debianubuntu-1)
   - [RPM-based](#rpm-based-1)
- [Run with nix](#run-with-nix)
   - [Nixpkgs](#nixpkgs)
      - [Run with flakes](#run-with-flakes)
      - [Install to configuration](#install-to-configuration)
      - [Overriding](#overriding)
   - [Built-in module](#built-in-module)
      - [Run with flakes](#run-with-flakes)
      - [Run old style](#run-old-style)
      - [Install to NixOS](#install-to-nixos)
   - [NixOS tests](#nixos-tests)
- [Star History](#star-history)


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

Tray mode is disabled by default. It allows program to be minimized to tray instead of closing. To enable it set `TRAY_ENABLED` option to `1`, `2` - mono black icon, `3` - mono white.

![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/5998ba7f-9ee7-4725-9d51-fbe5510a799d)

***

### Always leave to tray

By default, if the TRAY_ENABLED option is enabled, then if the player is paused, the application will close instead of minimizing to the system tray. The `ALWAYS_LEAVE_TO_TRAY=1` option changes this behavior.

***

### Dev tools

Chromium developer/debug tools can be enabled by setting `DEV_TOOLS` option to `1`.

***

### Custom title bar

Yandex Music's custom Windows-styled titlebar can be enabled by setting `CUSTOM_TITLE_BAR` option to `1`. Also makes the window frameless.

![image](https://github.com/user-attachments/assets/b3fa91f9-6ef6-44ec-9418-4ae8bf1be99b)

***

### Vibe animation FPS control

Vibe animation FPS can be control by setting `VIBE_ANIMATION_MAX_FPS` option from `0` (black screen) to any reasonable number. Recommended `25` - `144`. Default `25`.

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

You can build `pacman` package file manually using `PKGBUILD` file from the this repository. Run following commands in folder with `PKGBUILD` file inside to build and install the package:

```bash
makepkg -si
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

### Nixpkgs

The `yandex-music` package was
[introduced](https://github.com/NixOS/nixpkgs/pull/337425) to NixOS starting
from version 24.11.

#### Run with flakes

```bash
nix run nixpkgs#yandex-music
```

#### Install to configuration

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
#### NixOS tests

This project uses [NixOS Testing
framework](https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests) to
perform generic run-tests of NixOS module and built app.

It runs automatically by github actions, but you may want to perform tests on
your own PC.

The root flake exports package `tests` with symlinks to artefact of all tests.

So you can run them by

```bash
nix build .#tests
```

Each test is complete qemu VM with NixOS onboard and configured yandex-music
application. The test performs withing the result package building inside nix
sandbox. The simple python script perform all the basic checks. The tests are
differs between each other by configuration options to yandex-music module. You
can see all of them [here](./nix/test.nix#L46).

You can run each test separately as sub-attr of `tests` package, e.g:

```bash
nix build .#tests.trayMonoWhite
```

You may want to see logs of each test (even failed) with `nix log` command, e.g:

```bash
nix log .#tests.customTitleBar
```

## Star History

<a href="https://star-history.com/#cucumber-sp/yandex-music-linux&Timeline">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=cucumber-sp/yandex-music-linux&type=Timeline&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=cucumber-sp/yandex-music-linux&type=Timeline" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=cucumber-sp/yandex-music-linux&type=Timeline" />
 </picture>
</a>
