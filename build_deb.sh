#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0")  [-h] [-a <x64|armv7l|arm64|all> default=x64]"
    echo
    echo " Options:"
    echo " -a    Architecture to build for (<x64|armv7l|arm64|all> default=x64)"
    echo " -h    Show this help and exit"
}

x64=1
armv7l=0
arm64=0

#checking for arch option (if not specified set x64) and h option
while getopts :a:h name; do
    case $name in
    a)
        case $OPTARG in
        x64)
            x64=1
            ;;
        armv7l)
            armv7l=1
            x64=0
            ;;
        arm64)
            arm64=1
            x64=0
            ;;
        all)
            x64=1
            armv7l=1
            arm64=1
            ;;
        *)
            echo "Invalid architecture specified"
            usage
            exit 1
            ;;
        esac
        ;;
    h)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done

clear() {
    rm -rf "$TEMPDIR"
}
TEMPDIR="$(mktemp -d)"
trap clear EXIT

#loading version info with jq
version=$(jq -r '.version' ./utility/version_info.json)
exe_name=$(jq -r '.exe_name' ./utility/version_info.json)
exe_link=$(jq -r '.exe_link' ./utility/version_info.json)
exe_sha256=$(jq -r '.exe_sha256' ./utility/version_info.json)

#downloading exe
echo "Downloading $exe_name"
curl -L -o "$TEMPDIR/$exe_name" "$exe_link"

#checking sha256
echo "Checking sha256"
echo "$exe_sha256  $TEMPDIR/$exe_name" | sha256sum -c

echo "Repaking $exe_name"
sh repack.sh -o "$TEMPDIR/app" "$TEMPDIR/$exe_name"

#downloading electron binaries
if [ $x64 -eq 1 ]; then
    echo "Downloading electron x64"
    curl -L -o "$TEMPDIR/electron-x64.zip" "https://github.com/electron/electron/releases/download/v27.3.0/electron-v27.3.0-linux-x64.zip"
    unzip -q "$TEMPDIR/electron-x64.zip" -d "$TEMPDIR/electron-x64"
fi

if [ $armv7l -eq 1 ]; then
    echo "Downloading electron armv7l"
    curl -L -o "$TEMPDIR/electron-armv7l.zip" "https://github.com/electron/electron/releases/download/v27.3.0/electron-v27.3.0-linux-armv7l.zip"
    unzip -q "$TEMPDIR/electron-armv7l.zip" -d "$TEMPDIR/electron-armv7l"
fi

if [ $arm64 -eq 1 ]; then
    echo "Downloading electron arm64"
    curl -L -o "$TEMPDIR/electron-arm64.zip" "https://github.com/electron/electron/releases/download/v27.3.0/electron-v27.3.0-linux-arm64.zip"
    unzip -q "$TEMPDIR/electron-arm64.zip" -d "$TEMPDIR/electron-arm64"
fi

mkdir -p "deb"

#bulding packages
if [ $x64 -eq 1 ]; then
    echo "Building x64 package"
    pkgdir="$TEMPDIR/yandexmusic-x64"

    mkdir -p "$pkgdir/DEBIAN"
    cp "./templates/control" "$pkgdir/DEBIAN/control"
    sed -i "s/%version%/$version/g" "$pkgdir/DEBIAN/control"
    sed -i "s/%arch%/amd64/g" "$pkgdir/DEBIAN/control"

    mkdir -p "$pkgdir/usr/lib/yandexmusic"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/share/licenses/yandexmusic"
    mkdir -p "$pkgdir/usr/share/pixmaps"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$TEMPDIR/app/yandexmusic.asar" "$pkgdir/usr/lib/yandexmusic/yandexmusic.asar"
    install -Dm644 "$TEMPDIR/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandexmusic.png"
    install -Dm644 "./templates/desktop" "$pkgdir/usr/share/applications/yandexmusic.desktop"
    install -Dm644 "./LICENSE.md" "$pkgdir/usr/share/licenses/yandexmusic/LICENSE"
    mv "$TEMPDIR/electron-x64/" "$pkgdir/usr/lib/yandexmusic/electron"

    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandexmusic"
    echo 'exec /usr/lib/yandexmusic/electron/electron /usr/lib/yandexmusic/yandexmusic.asar "$@"' >> "$pkgdir/usr/bin/yandexmusic"
    chmod 755 "$pkgdir/usr/bin/yandexmusic"

    dpkg-deb --build "$pkgdir" "deb/yandexmusic_${version}_amd64.deb"
fi

if [ $armv7l -eq 1 ]; then
    echo "Building armv7l package"
    pkgdir="$TEMPDIR/yandexmusic-armv7l"

    mkdir -p "$pkgdir/DEBIAN"
    cp "./templates/control" "$pkgdir/DEBIAN/control"
    sed -i "s/%version%/$version/g" "$pkgdir/DEBIAN/control"
    sed -i "s/%arch%/armhf/g" "$pkgdir/DEBIAN/control"

    mkdir -p "$pkgdir/usr/lib/yandexmusic"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/share/licenses/yandexmusic"
    mkdir -p "$pkgdir/usr/share/pixmaps"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$TEMPDIR/app/yandexmusic.asar" "$pkgdir/usr/lib/yandexmusic/yandexmusic.asar"
    install -Dm644 "$TEMPDIR/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandexmusic.png"
    install -Dm644 "./templates/desktop" "$pkgdir/usr/share/applications/yandexmusic.desktop"
    install -Dm644 "./LICENSE.md" "$pkgdir/usr/share/licenses/yandexmusic/LICENSE"
    mv "$TEMPDIR/electron-armv7l/" "$pkgdir/usr/lib/yandexmusic/electron"

    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandexmusic"
    echo 'exec /usr/lib/yandexmusic/electron/electron /usr/lib/yandexmusic/yandexmusic.asar "$@"' >> "$pkgdir/usr/bin/yandexmusic"
    chmod 755 "$pkgdir/usr/bin/yandexmusic"

    dpkg-deb --build "$pkgdir" "deb/yandexmusic_${version}_armhf.deb"
fi

if [ $arm64 -eq 1 ]; then
    echo "Building arm64 package"
    pkgdir="$TEMPDIR/yandexmusic-arm64"

    mkdir -p "$pkgdir/DEBIAN"
    cp "./templates/control" "$pkgdir/DEBIAN/control"
    sed -i "s/%version%/$version/g" "$pkgdir/DEBIAN/control"
    sed -i "s/%arch%/arm64/g" "$pkgdir/DEBIAN/control"

    mkdir -p "$pkgdir/usr/lib/yandexmusic"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/share/licenses/yandexmusic"
    mkdir -p "$pkgdir/usr/share/pixmaps"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$TEMPDIR/app/yandexmusic.asar" "$pkgdir/usr/lib/yandexmusic/yandexmusic.asar"
    install -Dm644 "$TEMPDIR/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandexmusic.png"
    install -Dm644 "./templates/desktop" "$pkgdir/usr/share/applications/yandexmusic.desktop"
    install -Dm644 "./LICENSE.md" "$pkgdir/usr/share/licenses/yandexmusic/LICENSE"
    mv "$TEMPDIR/electron-arm64/" "$pkgdir/usr/lib/yandexmusic/electron"

    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandexmusic"
    echo 'exec /usr/lib/yandexmusic/electron/electron /usr/lib/yandexmusic/yandexmusic.asar "$@"' >> "$pkgdir/usr/bin/yandexmusic"
    chmod 755 "$pkgdir/usr/bin/yandexmusic"

    dpkg-deb --build "$pkgdir" "deb/yandexmusic_${version}_arm64.deb"
fi