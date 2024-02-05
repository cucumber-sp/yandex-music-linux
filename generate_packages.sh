#!/bin/bash

set -e

TEMPDIR=
exe_link=
version=
exe_name=
exe_sha256=

clear() {
    rm -rf "$TEMPDIR"
}
TEMPDIR="$(mktemp -d)"
trap clear EXIT

check_dep() {
    if ! command -v "$@" &>/dev/null; then
        echo "$@" not installed. >&2
        return 1
    fi
}

check_deps() {
    check_dep sed
    check_dep curl
    check_dep jq
}

load_current_version() {
    # loading json from file https://music-desktop-application.s3.yandex.net/stable/download.json
    curl -s https://music-desktop-application.s3.yandex.net/stable/download.json > "$TEMPDIR"/download.json

    exe_link=$(jq -r '.windows' "$TEMPDIR"/download.json)
    version="$(echo "$exe_link" | grep -oP '(?<=x64_).*(?=.exe)')"
    exe_name="$(basename "$exe_link")"

    echo "Windows url: $exe_link"
    echo "Version: $version"
    echo "Exe name: $exe_name"

    curl "$exe_link" > "$TEMPDIR/$exe_name"

    exe_sha256="$(sha256sum "$TEMPDIR/$exe_name" | awk '{print $1}')"

    echo "Exe sha256: $exe_sha256"
}

update_version() {
    rm -rf ./version_info.json

    cat > ./version_info.json <<EOF
{
    "version": "$version",
    "exe_name": "$exe_name",
    "exe_link": "$exe_link",
    "exe_sha256": "$exe_sha256"
}
EOF

}

update_pkbuild() {
    cp ./templates/PKGBUILD ./PKGBUILD

    sed -i "s#%version%#$version#g" ./PKGBUILD
    sed -i "s#%release%#1#g" ./PKGBUILD
    sed -i "s#%exe_name%#$exe_name#g" ./PKGBUILD
    sed -i "s#%exe_link%#$exe_link#g" ./PKGBUILD
    sed -i "s#%exe_sha256%#$exe_sha256#g" ./PKGBUILD
}

update_flake() {
    sed -i 's#\(ymExe\.url\s*=\s*\).*;#\1'"$exe_link"';#' ./flake.nix
    if check_dep nix; then
        nix --extra-experimental-features 'nix-command flakes' flake update
    else
        echo "flake.nix was updated, but nix is not installed to update flake.lock"
    fi
}

check_deps
load_current_version
update_version
update_pkbuild
update_flake
