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

echo "Fixing App Quiting"
sed -i "s/window.on('close', (event) => {/window.on('close', (event) => {electron_1.app.quit();/g" "./main/lib/handlers/handleWindowLifecycleEvents.js"

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install jq to proceed." >&2
  exit 1
fi

jq --arg license "UNLICENSED" '. + {license: $license}' package.json > tmp_package.json
mv tmp_package.json package.json
echo "Updated license field in package.json"
version=$(jq -r .version package.json)

jq '. + icon: {"48x48": "build/next-desktop/favicon.png", "scalable": "build/next-desktop/favicon.svg"}' package.json > tmp_package.json
mv tmp_package.json package.json
echo "Updated icon field in package.json"

if [ -n "$extract_only" ]; then
    exit 0
fi

cd ../
mkdir out

echo "Packing"
asar pack "./app" "./out/yandexmusic.asar"

rm -rf ./app

echo "Done"

cp "./LICENSE.md" "./out/LICENSE.md"
cp "./templates/desktop" "./out/yandexmusic.desktop"

#sha256 hash
asar_hash=$(sha256sum "./out/yandexmusic.asar" | cut -d ' ' -f 1)
desktop_hash=$(sha256sum "./out/yandexmusic.desktop" | cut -d ' ' -f 1)

echo "asar hash: $asar_hash"
echo "desktop hash: $desktop_hash"

echo "Building PKGBUILD"

cp "./templates/PKGBUILD" "./out/PKGBUILD"
sed -i "s/%version%/$version/g" "./out/PKGBUILD"
sed -i "s/%asar_hash%/$asar_hash/g" "./out/PKGBUILD"
sed -i "s/%desktop_hash%/$desktop_hash/g" "./out/PKGBUILD"

echo "Done"