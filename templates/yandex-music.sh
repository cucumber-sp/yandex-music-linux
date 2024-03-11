#!/bin/bash

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
CONFIG_FILE_NAME=yandex-music-flags.conf

if [[ -f $XDG_CONFIG_HOME/$CONFIG_FILE_NAME ]]; then
   YANDEX_MUSIC_USER_FLAGS="$(sed 's/#.*//' $XDG_CONFIG_HOME/$CONFIG_FILE_NAME | tr '\n' ' ')"
   echo "User flags:" "${YANDEX_MUSIC_USER_FLAGS[@]}"
fi

# Launch
exec electron28 /usr/lib/yandex-music/yandex-music.asar $YANDEX_MUSIC_USER_FLAGS "$@" 
