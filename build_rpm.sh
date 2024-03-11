#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0")  [-h] [-a <x64|armv7l|arm64|all> default=x64]"
    echo
    echo " Options:"
    echo " -a    Architecture to build for (<x64|armv7l|arm64|all> default=x64)"
    echo " -h    Show this help and exit"
}

prepare_tarball(){
    arch=${1}
    echo "Preparing tarball for ${arch}"
    if [ ! -f "tar/yandex-music_${version}_${arch}.tar.gz" ]; then
        echo "Building tarball for ${arch}"
        bash build_tarball.sh -a "${arch}"
    fi
    cp "tar/yandex-music_${version}_${arch}.tar.gz" "${TEMPDIR}/yandex-music_${version}_${arch}.tar.gz"
    cd "${TEMPDIR}"
    tar -xzf "yandex-music_${version}_${arch}.tar.gz"
    mkdir -p "yandex-music-${version}"
    mv usr "yandex-music-${version}"
    tar -czf "yandex-music_${version}_${arch}.tar.gz" "yandex-music-${version}"
    rm -rf "yandex-music-${version}"
    cd "${INITIAL_DIR}"
    cp "${TEMPDIR}/yandex-music_${version}_${arch}.tar.gz" "${TEMPDIR}/rpmbuild/SOURCES/yandex-music_${version}_${arch}.tar.gz"
}

build_rpm(){
    arch=${1}
    pkgarch=${2}
    echo "Building ${arch} package"
    cp "templates/rpm.spec" "${TEMPDIR}/rpmbuild/SPECS/${arch}.spec"
    sed -i "s/%version%/${version}/g" "${TEMPDIR}/rpmbuild/SPECS/${arch}.spec"
    sed -i "s/%arch%/${pkgarch}/g" "${TEMPDIR}/rpmbuild/SPECS/${arch}.spec"
    sed -i "s/%source_tarball%/yandex-music_${version}_${arch}.tar.gz/g" "${TEMPDIR}/rpmbuild/SPECS/${arch}.spec"
    rpmbuild --define "_topdir ${TEMPDIR}/rpmbuild" -bb "${TEMPDIR}/rpmbuild/SPECS/${arch}.spec"
    cp "${TEMPDIR}/rpmbuild/RPMS/${pkgarch}/yandex-music-${version}-1.${pkgarch}.rpm" "rpm/yandex-music-${version}-1.${pkgarch}.rpm"
}

init_rpm(){
    echo "Initializing RPM build"
    mkdir -p "${TEMPDIR}/rpmbuild/SOURCES"
    mkdir -p "${TEMPDIR}/rpmbuild/SPECS"
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
INITIAL_DIR=${PWD}
trap clear EXIT

#loading version info with jq
version=$(jq -r '.ym.version' ./utility/version_info.json)

init_rpm
mkdir -p "rpm"

if [ ${x64} -eq 1 ]; then
    prepare_tarball "x64"
    build_rpm "x64" "x86_64"
fi

if [ ${armv7l} -eq 1 ]; then
    prepare_tarball "armv7l"
    build_rpm "armv7l" "armv7hl"
fi

if [ ${arm64} -eq 1 ]; then
    prepare_tarball "arm64"
    build_rpm "arm64" "aarch64"
fi