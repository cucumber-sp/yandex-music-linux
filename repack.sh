#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0") [-xqh] [ -o DIR] YANDEX_MUSIC_EXE"
    echo
    echo " Options:"
    echo " -o DIR Path to destination folder"
    echo " -x     Extract and fix only to destination folder"
    echo " -q     Do not apply application quit fix"
    echo " -h     Show this help and exit"
}

exe_location=
dst="$PWD/app"
fix_quit=1
while getopts :xo:qh name; do
    case $name in
    x) extract_only=1 ;;
    o) dst="$OPTARG" ;;
    q) fix_quit=0 ;;
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

clear() {
    rm -rf "$TEMPDIR"
}
TEMPDIR="$(mktemp -d)"
trap clear EXIT


EXTRACTED="$TEMPDIR/Extracted"
# unpacking
7z x "$exe_location" -o"$EXTRACTED"
mv "$EXTRACTED/\$PLUGINSDIR/app-64.7z" "$TEMPDIR/app-64.7z"
rm -rf "$EXTRACTED"
7z x "$TEMPDIR/app-64.7z" -o"$EXTRACTED"
mv "$EXTRACTED/resources/app.asar" "$TEMPDIR/app.asar"
rm -rf "$EXTRACTED"
rm "$TEMPDIR/app-64.7z"
npx asar extract "$TEMPDIR/app.asar" "$TEMPDIR/app"
rm "$TEMPDIR/app.asar"

curdir="$PWD"
cd "$TEMPDIR/app"

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

if [ "$fix_quit" == "1" ]; then
    echo "Fixing App Quiting"
    sed -i "s/window.on('close', (event) => {/window.on('close', (event) => {electron_1.app.quit();/g" \
        "./main/lib/handlers/handleWindowLifecycleEvents.js"
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install jq to proceed." >&2
  exit 1
fi

jq --arg license "UNLICENSED" '. + {license: $license}' package.json > tmp_package.json
mv tmp_package.json package.json
echo "Updated license field in package.json"

jq '. + {icon: {"48x48": "build/next-desktop/favicon.png", "scalable": "build/next-desktop/favicon.svg"}}' package.json > tmp_package.json
mv tmp_package.json package.json
echo "Updated icon field in package.json"

if [ -n "$extract_only" ]; then
    mkdir -p "$(dirname "$dst")"
    mv "$TEMPDIR/app" "$dst"
    exit 0
fi

mkdir -p "$dst"

echo "Packing"
cd "$curdir"
npx asar pack "$TEMPDIR/app" "$dst/yandexmusic.asar"
for ext in png svg; do
    mv "$TEMPDIR/app/build/next-desktop/favicon.$ext" "$dst"
done

echo "Done"
