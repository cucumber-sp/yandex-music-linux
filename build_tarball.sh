#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0")  [-h] [-a <x64|armv7l|arm64|all> default=x64]"
    echo
    echo " Options:"
    echo " -a    Architecture to build for (<x64|armv7l|arm64|all> default=x64)"
    echo " -o    Output directory"
    echo " -h    Show this help and exit"
}

download_electron_binary(){
    arch=${1}
    echo "Downloading electron ${arch}"
    LINK=$(jq -r .electron."${arch}" ./utility/version_info.json)
    curl -L -o "${TEMPDIR}/electron-${arch}.zip" "${LINK}"
    unzip -q "${TEMPDIR}/electron-${arch}.zip" -d "${TEMPDIR}/electron-${arch}"
}

build_tarball(){
    arch=${1}
    app_dir="${TEMPDIR}/yandex-music_${version}_${arch}"

    mkdir -p "${app_dir}/usr/lib/yandex-music"
    mkdir -p "${app_dir}/usr/share/applications"
    mkdir -p "${app_dir}/usr/share/licenses/yandex-music"
    mkdir -p "${app_dir}/usr/share/pixmaps"
    mkdir -p "${app_dir}/usr/bin"

    install -Dm644 "${TEMPDIR}/app/yandex-music.asar" "${app_dir}/usr/lib/yandex-music/yandex-music.asar"

    install -Dm644 "${TEMPDIR}/app/favicon.png" "${app_dir}/usr/share/pixmaps/yandex-music.png"
    install -Dm644 "${TEMPDIR}/app/favicon.png" "${app_dir}/usr/share/icons/hicolor/48x48/apps/yandex-music.png"
    install -Dm644 "${TEMPDIR}/app/favicon.svg" "${app_dir}/usr/share/icons/hicolor/scalable/apps/yandex-music.svg"

    install -Dm644 "./templates/desktop" "${app_dir}/usr/share/applications/yandex-music.desktop"
    install -Dm644 "./templates/default.conf" "${app_dir}/usr/lib/yandex-music/default.conf"
    install -Dm644 "./LICENSE.md" "${app_dir}/usr/share/licenses/yandex-music/LICENSE"
    mv "${TEMPDIR}/electron-${arch}/" "${app_dir}/usr/lib/yandex-music/electron"

    install -Dm755 "./templates/yandex-music.sh" "${app_dir}/usr/bin/yandex-music"
    sed -i "s|%electron_path%|/usr/lib/yandex-music/electron/electron|g" "${app_dir}/usr/bin/yandex-music"
    sed -i "s|%asar_path%|/usr/lib/yandex-music/yandex-music.asar|g" "${app_dir}/usr/bin/yandex-music"

    cd "${app_dir}"
    tar -czf "${OUTPUT_DIR}/yandex-music_${version}_${arch}.tar.gz" *
    cd "${INITIAL_DIR}"
}

INITIAL_DIR="${PWD}"
OUTPUT_DIR="${PWD}/tar"
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
version=$(jq -r '.ym.version' ./utility/version_info.json)
exe_name=$(jq -r '.ym.exe_name' ./utility/version_info.json)
exe_link=$(jq -r '.ym.exe_link' ./utility/version_info.json)
exe_sha256=$(jq -r '.ym.exe_sha256' ./utility/version_info.json)

#downloading exe
echo "Downloading ${exe_name}"
curl -L -o "${TEMPDIR}/${exe_name}" "${exe_link}"

#checking sha256
echo "Checking sha256"
echo "${exe_sha256}  ${TEMPDIR}/${exe_name}" | sha256sum -c

echo "Repaking ${exe_name}"
bash repack.sh -o "${TEMPDIR}/app" "${TEMPDIR}/${exe_name}"

mkdir -p "${OUTPUT_DIR}"

if [ ${x64} -eq 1 ]; then
    download_electron_binary "x64"
    build_tarball "x64"
fi

if [ ${armv7l} -eq 1 ]; then
    download_electron_binary "armv7l"
    build_tarball "armv7l"
fi

if [ ${arm64} -eq 1 ]; then
    download_electron_binary "arm64"
    build_tarball "arm64"
fi
