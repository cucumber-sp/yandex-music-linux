# yandex-music-linux

## About
Native YandexMusic client for Linux. Built using repacking of Windows client (Electron app).

## Table of content
- [Screenshots](#screenshots)
- [Installation](#installation)
   - [Arch Linux](#arch-linux)
   - [Debian/Ubuntu](#debianubuntu)
- [Manual Build](#manual-build)
   - [Prerequisites](#prerequisites)
   - [Extract app only](#extract-app-only)
   - [ASAR archive](#asar-archive)
   - [Arch Linux](#arch-linux-1)
   - [Debian/Ubuntu](#debianubuntu-1)
- [Run with nix](#run-with-nix)
   - [Run with flakes](#run-with-flakes)
   - [Run old style](#run-old-style)
   - [Install to NixOS](#install-to-nixos)

## Screenshots
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/ab2f69ee-efc4-4a33-8110-131b4c4ff4de)
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/de618654-15d1-4103-a323-faa00086d0a2)


## Installation

### Arch Linux

***

#### AUR

You can obtain the latest version of package from `AUR` using one of the [AUR Helpers](https://wiki.archlinux.org/title/AUR_helpers). Then install it with `yandexmusic` as package name.

For this example I will use [yay](https://github.com/Jguer/yay)

```
yay -S yandexmusic
```

#### Binary package file

Download prebuilt binary package from [Releases](https://github.com/cucumber-sp/yandex-music-linux/releases) section.

Then you can install it with the following command

```
pacman -U yandexmusic-<version>-any.pkg.tar.zst
```

***

### Debian/Ubuntu

***

#### APT

Package is currently unavailable at APT. We're still working on it

#### Binary package file

Download prebuilt binary package from [Releases](https://github.com/cucumber-sp/yandex-music-linux/releases) section.

Then you can install it with the following command

```
dpkg -i yandexmusic_<version>_<arch>.deb
```

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
```

In addition you will need to install [Asar](https://github.com/electron/asar) tool with `npm`. I recommend install it globally with the following command

```
npm install -g @electron/asar
```

Last step is to download original client `.exe` file. You can get it yourself or take link to the latest version from `version_info.json` file.

***

### Extract app only

If you only want to get extracted app project with applied patches, you can use the following command:

```
sh repack.sh -x [-o OUTPUT_DIR default=./app] <YM.exe>
```
***

### ASAR archive

`.asar` is archive file that containes all electron app resources and information, but doesn't hold Electron binaries. If you have `.asar` file you can launch app using `electron <app>.asar`. You can build this archive with the following command:

```
sh repack.sh [-o OUTPUT_DIR default=./app] <YM.exe>
```

***

### Arch Linux

You can build `pacman` package file manually using `PKGBUILD` file from the this repository. Run following commands in folder with `PKGBUILD` file inside to get `.pkg.tar.zst` package:

```
pacman -S electron libpulse
makepkg
```

***

### Debian/Ubuntu

You can build `.deb` binary package using the following command:

```
sh build_deb.sh  [-a <x64|armv7l|arm64|all> default=x64]
```

***

## Run with nix

The `yandexmusic` package has unlicensed license, so you need to have
`allowUnfree` option enabled.

### Run with flakes

Execute next to build and run yandex music directly from github

```
nix run github:cucumber-sp/yandex-music-linux
```

### Run old style

Execute next in this repository to build yandexmusic package without using
flakes.

```
nix-build --expr '(import <nixpkgs> {}).callPackage ./nix {}'
```

### Install to NixOS

This flake exports `modules` list. Append it to your system modules and add
`yandexmusic` package to `environment.systemPackages`.
