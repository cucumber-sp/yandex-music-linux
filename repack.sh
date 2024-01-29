#!/bin/bash

set -e
prompt_yes_no() {
    local question="$1"
    local response
    while true; do
        read -rp "$question (y/n): " response
        case $response in
            [Yy]*)
                return 0  # Returning success status code
                ;;
            [Nn]*)
                return 1  # Returning failure status code
                ;;
            *)
                echo "Please enter 'y' (yes) or 'n' (no)."
                ;;
        esac
    done
}

usage() {
    echo "Usage: $(basename "$0") [-xh] YANDEX_MUSIC_EXE"
    echo
    echo " Options:"
    echo " -x     Extract and fix only to ./app folder"
    echo " -h     Show this help and exit"
}

extract_only=
exe_location=
while getopts :xh name; do
    case $name in
    x) extract_only=1 ;;
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

if [ "$OPTIND" -le "$#" ]; then
    shift "$(( OPTIND - 1))"
    exe_location="$1"
fi


if [ -z "$exe_location" ]; then
    echo "No exe file specified"
    usage
    exit 1
fi

# unpacking
7z x "$exe_location" -oExtracted
cp "./Extracted/\$PLUGINSDIR/app-64.7z" "./app-64.7z"
rm -rf ./Extracted
7z x "./app-64.7z" -oExtracted
cp "./Extracted/resources/app.asar" "./app.asar"
rm -rf ./Extracted
rm ./app-64.7z
asar extract "./app.asar" "./app"
rm "./app.asar"

cd ./app

# fixing secretKey issue
echo "Fixing SecretKey"
find "./" -type f \( -name "*.js" -o -name "*.js.map" \) -print0 | while IFS= read -r -d $'\0' file; do
    # Use 'sed' to perform the replacement in-place
    sed -i "s/secretKey:this.secretKey/secretKey:'superSecretKey'/g" "$file"
done
echo "SecretKey replaced"


echo "Fixing Title"
#fixing title
find "./" -type f -name "*.html" -print0 | while IFS= read -r -d $'\0' file; do
    # Use 'sed' to perform the replacement in-place
    sed -i "s/Яндекс Музыка — собираем музыку для вас/Яндекс Музыка/g" "$file"
done
echo "Title Fixed"

if [ -n "$extract_only" ]; then
    exit 0
fi

# managing npm dependencies
npm uninstall @yandex-chats/signer
npm uninstall electron-notarize
npm install @electron/notarize --save-dev
npm install --save-dev @electron-forge/cli
npx electron-forge import

echo Copy forge.config.js and desktop.ejs...
cp ../forge.config.js ../desktop.ejs .

update_license=0
if prompt_yes_no "In order to build the app we'll need to update the license field in package.json. Continue?"; then
    update_license=1
fi

if [ "$update_license" -eq 0 ]; then
    exit 0
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install jq to proceed." >&2
  exit 1
fi
jq --arg license "UNLICENSED" '. + {license: $license}' package.json > tmp_package.json
mv tmp_package.json package.json
echo "Updated license field in package.json"
version=$(jq -r .version package.json)

build_x64=0
build_arm64=0

if prompt_yes_no "Build for x64?"; then
    build_x64=1
fi

if prompt_yes_no "Build for arm64?"; then
    build_arm64=1
fi

# building
if [ "$build_x64" -eq 1 ]; then
    npx electron-forge make --arch="x64"
fi

if [ "$build_arm64" -eq 1 ]; then
    npx electron-forge make --arch="arm64"
fi

# moving packages and rename them
cd ../
mkdir out
if [ "$build_x64" -eq 1 ]; then
    debpath=$(find "./app/out/make/deb/x64/" -type f -print -quit)
    rpmpath=$(find "./app/out/make/rpm/x64/" -type f -print -quit)
    zippath=$(find "./app/out/make/zip/linux/x64/" -type f -print -quit)
    newdeb="./out/yandexmusic.$version.x64.deb"
    newrpm="./out/yandexmusic.$version.x64.rpm"
    newzip="./out/yandexmusic.$version.x64.zip"
    mv "$debpath" "$newdeb"
    mv "$rpmpath" "$newrpm"
    mv "$zippath" "$newzip"
fi

if [ "$build_arm64" -eq 1 ]; then
    debpath=$(find "./app/out/make/deb/arm64/" -type f -print -quit)
    rpmpath=$(find "./app/out/make/rpm/arm64/" -type f -print -quit)
    zippath=$(find "./app/out/make/zip/linux/arm64/" -type f -print -quit)
    newdeb="./out/yandexmusic.$version.arm64.deb"
    newrpm="./out/yandexmusic.$version.arm64.rpm"
    newzip="./out/yandexmusic.$version.arm64.zip"
    mv "$debpath" "$newdeb"
    mv "$rpmpath" "$newrpm"
    mv "$zippath" "$newzip"
fi

rm -rf ./app
