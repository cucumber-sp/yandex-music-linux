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
        pacman -S --noconfirm git sudo base-devel jq nix
        sh ./generate_packages.sh
        git config --global --add safe.directory "*"
        ;;
    *)
        echo "Operating system is not recognized."
        ;;
esac