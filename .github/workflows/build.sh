#!/bin/bash

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
        pacman -S --noconfirm git sudo base-devel p7zip nodejs jq npm electron libpulse dpkg unzip
        # fix access
        mkdir /.npm
        chown -R 65534:65534 "/.npm"
        # fix "asar: command not found"
        npm install -g @electron/asar
        # fix makepkg from non-root
        mkdir /home/build
        chgrp nobody /home/build
        chmod g+ws /home/build
        setfacl -m u::rwx,g::rwx /home/build
        setfacl -d --set u::rwx,g::rwx,o::- /home/build
        chown nobody .
        sh ./generate_packages.sh
        sudo -u nobody makepkg --log
        
        mkdir dist
        mv *.pkg.tar.zst dist

        mv ./src/app/yandexmusic.asar dist/yandexmusic.asar

        sh ./build_deb.sh -a all
        mv deb/*.deb dist
        ;;
    "Ubuntu")
        echo NixOS
        sh ./generate_packages.sh
        export NIXPKGS_ALLOW_UNFREE=1
        nix build --impure
        ;;
    *)
        echo "Operating system is not recognized."
        ;;
esac