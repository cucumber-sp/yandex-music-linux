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
    "Ubuntu")
        echo Ubuntu
        apt-get update
        apt-get install -y jq curl p7zip-full nodejs npm unzip jq
        npm install -g @electron/asar
        sh ./build_deb.sh -a all

        mkdir dist
        mv deb/*.deb dist
        ;;
    "Arch Linux")
        echo "Arch Linux"
        pacman -Syy --noconfirm
        pacman -S --noconfirm git sudo base-devel p7zip nodejs jq npm electron libpulse 
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
        sudo -u nobody makepkg --log
        
        mkdir dist
        mv *.pkg.tar.zst dist
        ;;
#    "NixOS")
#        echo NixOS
#        nix build
#        ;;
    *)
        echo "Operating system is not recognized."
        ;;
esac