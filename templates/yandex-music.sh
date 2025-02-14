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
    WAYLAND_FLAGS="--ozone-platform=wayland"
fi

ELECTRON_BIN=${ELECTRON_CUSTOM_BIN:-%electron_path%}

export TRAY_ENABLED=${TRAY_ENABLED:-0}
export DEV_TOOLS=${DEV_TOOLS:-0}
export CUSTOM_TITLE_BAR=${CUSTOM_TITLE_BAR:-0}
export VIBE_ANIMATION_MAX_FPS=${VIBE_ANIMATION_MAX_FPS:-25}

exec "${ELECTRON_BIN}" "%asar_path%" $ELECTRON_ARGS $WAYLAND_FLAGS
