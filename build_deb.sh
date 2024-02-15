#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0")  [-h] [-a <x64|armv7l|arm64|all> default=x64]"
    echo
    echo " Options:"
    echo " -a    Architecture to build for (<x64|armv7l|arm64|all> default=x64)"
    echo " -h    Show this help and exit"
}

download_electron_binary(){
    arch=${1}
    echo "Downloading electron ${arch}"
    curl -L -o "${TEMPDIR}/electron-${arch}.zip" "https://github.com/electron/electron/releases/download/v27.3.0/electron-v27.3.0-linux-${arch}.zip"
    unzip -q "${TEMPDIR}/electron-${arch}.zip" -d "${TEMPDIR}/electron-${arch}"
}

build_deb(){
    arch=${1}
    pkgarch=${2}

    echo "Building ${arch} package"
    pkgdir="${TEMPDIR}/yandex-music-${arch}"

    mkdir -p "${pkgdir}/DEBIAN"
    cp "./templates/control" "${pkgdir}/DEBIAN/control"
    sed -i "s/%version%/${version}/g" "${pkgdir}/DEBIAN/control"
    sed -i "s/%arch%/${pkgarch}/g" "${pkgdir}/DEBIAN/control"

    mkdir -p "${pkgdir}/usr/lib/yandex-music"
    mkdir -p "${pkgdir}/usr/share/applications"
    mkdir -p "${pkgdir}/usr/share/licenses/yandex-music"
    mkdir -p "${pkgdir}/usr/share/pixmaps"
    mkdir -p "${pkgdir}/usr/bin"

    install -Dm644 "${TEMPDIR}/app/yandex-music.asar" "${pkgdir}/usr/lib/yandex-music/yandex-music.asar"
    install -Dm644 "${TEMPDIR}/app/favicon.png" "${pkgdir}/usr/share/pixmaps/yandex-music.png"
    install -Dm644 "./templates/desktop" "${pkgdir}/usr/share/applications/yandex-music.desktop"
    install -Dm644 "./LICENSE.md" "${pkgdir}/usr/share/licenses/yandex-music/LICENSE"
    mv "${TEMPDIR}/electron-${arch}/" "${pkgdir}/usr/lib/yandex-music/electron"

    echo "#!/bin/sh" > "${pkgdir}/usr/bin/yandex-music"
    echo 'exec /usr/lib/yandex-music/electron/electron /usr/lib/yandex-music/yandex-music.asar "$@"' >> "${pkgdir}/usr/bin/yandex-music"
    chmod 755 "${pkgdir}/usr/bin/yandex-music"

    dpkg-deb --build "${pkgdir}" "deb/yandex-music_${version}_${pkgarch}.deb"
}

x64=0
armv7l=0
arm64=0

#checking for arch option (if not specified set x64) and h option
while getopts :a:h name; do
    case ${name} in
    a)
        case ${OPTARG} in
        x64) x64=1 ;;
        armv7l) armv7l=1 ;;
        arm64) arm64=1 ;;
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

#checking if at least one arch is specified else set x64
if [ ${x64} -eq 0 ] && [ ${armv7l} -eq 0 ] && [ ${arm64} -eq 0 ]; then
    x64=1
fi

clear() {
    rm -rf "${TEMPDIR}"
}
TEMPDIR="$(mktemp -d)"
trap clear EXIT

#loading version info with jq
version=$(jq -r '.version' ./utility/version_info.json)
exe_name=$(jq -r '.exe_name' ./utility/version_info.json)
exe_link=$(jq -r '.exe_link' ./utility/version_info.json)
exe_sha256=$(jq -r '.exe_sha256' ./utility/version_info.json)

#downloading exe
echo "Downloading ${exe_name}"
curl -L -o "${TEMPDIR}/${exe_name}" "${exe_link}"

#checking sha256
echo "Checking sha256"
echo "${exe_sha256}  ${TEMPDIR}/${exe_name}" | sha256sum -c

echo "Repaking ${exe_name}"
sh repack.sh -o "${TEMPDIR}/app" "${TEMPDIR}/${exe_name}"

mkdir -p "deb"

if [ ${x64} -eq 1 ]; then
    download_electron_binary "x64"
    build_deb "x64" "amd64"
fi

if [ ${armv7l} -eq 1 ]; then
    download_electron_binary "armv7l"
    build_deb "armv7l" "armhf"
fi

if [ ${arm64} -eq 1 ]; then
    download_electron_binary "arm64"
    build_deb "arm64" "arm64"
fi