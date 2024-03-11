#!/bin/bash

ELECTRON_PATH=$(tr '\n' ' ' < /usr/lib/yandex-music/electron-path)

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    WAYLAND_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi

# Launch
exec ${ELECTRON_PATH} /usr/lib/yandex-music/yandex-music.asar ${WAYLAND_FLAGS} "$@"
