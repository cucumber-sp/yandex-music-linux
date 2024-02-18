#!/bin/bash

set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
else
    OS=$(uname -s)
fi

case $OS in
    "Arch Linux")
        echo "Arch Linux"
        pacman -Syy --noconfirm
        pacman -S --noconfirm git sudo base-devel p7zip nodejs jq asar electron27 libpulse dpkg unzip xdg-utils python
        # fix makepkg from non-root
        mkdir /home/build
        chgrp nobody /home/build
        chmod g+ws /home/build
        setfacl -m u::rwx,g::rwx /home/build
        setfacl -d --set u::rwx,g::rwx,o::- /home/build
        chown nobody .
        sudo -u nobody makepkg --log

        mkdir dist
        mv *.pkg.tar.zst dist

        mv ./src/app/yandex-music.asar dist/yandex-music.asar
        mv ./src/app/release_notes.json dist/release_notes.json

        sh ./build_deb.sh -a all
        mv deb/*.deb dist
        ;;
    "Ubuntu")
        echo NixOS
        export NIXPKGS_ALLOW_UNFREE=1
        nix build --impure
        ;;
    *)
        echo "Operating system is not recognized."
        ;;
esac
