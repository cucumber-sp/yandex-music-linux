#!/bin/bash

set -e

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_FILE="${YANDEX_MUSIC_CONFIG:-$CONFIG_HOME/yandex-music.conf}"

echo "Using config file: ${CONFIG_FILE}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found, copying default"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp /usr/lib/yandex-music/default.conf "$CONFIG_FILE"
fi

source "$CONFIG_FILE"

WAYLAND_FLAGS=""
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    WAYLAND_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi

if [ -z "$ELECTRON_BIN" ]; then
    echo "ELECTRON_BIN is not set"
    exit 1
fi

exec "${ELECTRON_BIN}" /usr/lib/yandex-music/yandex-music.asar "${ELECTRON_ARGS}" "${WAYLAND_FLAGS}" 