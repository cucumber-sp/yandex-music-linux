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
        pacman -S --noconfirm git sudo base-devel jq nix
        git config --global --add safe.directory "*"
        sh ./utility/generate_packages.sh
        ;;
    *)
        echo "Operating system is not recognized."
        ;;
esac
