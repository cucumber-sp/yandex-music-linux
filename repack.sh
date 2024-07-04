#!/bin/bash

set -e

usage() {
    echo "Usage: $(basename "$0") [-xqh] [ -o DIR] YANDEX_MUSIC_EXE"
    echo
    echo " Options:"
    echo " -o DIR Path to destination folder"
    echo " -x     Extract and fix only to destination folder"
    echo " -p     Do not apply patches"
    echo " -h     Show this help and exit"
}

exe_location=
dst="$PWD/app"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
nopatch=0
while getopts :xo:ph name; do
    case $name in
    x) extract_only=1 ;;
    o) dst="$(realpath "$OPTARG")" ;;
    p) nopatch=1 ;;
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
asar extract "$TEMPDIR/app.asar" "$TEMPDIR/app"
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

# fixing titile
echo "Fixing Title"
find "./" -type f -name "*.html" -print0 | while IFS= read -r -d $'\0' file; do
    # Use 'sed' to perform the replacement in-place
    sed -i "s/Яндекс Музыка — собираем музыку для вас/Яндекс Музыка/g" "$file"
done
echo "Title Fixed"

echo "Replacing Icons"
cp -drf "$SCRIPT_DIR/icons/." "./app/"
echo "Replaced Icons"

# applying patches

# This function accepts patch file. If it names starts with `XXXX-optional`,
# then this function check is there the variable with tail name of patch and
# prefix patch_ defined to 1 and apply conditionally the patch. So, if the passed
# file has name `0003-optional-some-magic-feature.patch` the function will apply
# it only when the variable `patch_some_magic_feature` defined to `1`.
apply_patch()
{
    local patchfile patchname re

    patchfile="$(realpath "$1")"
    patchname="$(basename "$patchfile")"
    patchname="${patchname,,}"
    re='[[:digit:]]+\-optional\-(.+).patch ]]'
    if [[ $patchname =~ $re ]]; then
        patchname="${BASH_REMATCH[1]}"
        patchname="${patchname//[- ]/_}"
        if eval [ \"\$"patch_$patchname"\" != 1 ]; then
            echo "Skipping patch '$patchfile'"
            return 0
        fi
    fi
    echo "Applying patch '$patchfile'"
    (cd "$TEMPDIR/app" && patch -p1 < "$patchfile")
}

if [ "$nopatch" != "1" ]; then
    for f in $(eval echo "$SCRIPT_DIR"/patches/*.patch); do
        apply_patch "$f"
    done
fi

mkdir -p "$dst"

if [ -n "$extract_only" ]; then
    eval cp -r "$TEMPDIR/app/*" "$dst"
    exit 0
fi

echo "Packing"
cd "$curdir"
asar pack "$TEMPDIR/app" "$dst/yandex-music.asar"
for ext in png svg; do
    mv "$TEMPDIR/app/app/favicon.$ext" "$dst"
done
python "$SCRIPT_DIR/utility/extract_release_notes.py" "$TEMPDIR/app/main/translations/compiled/ru.json" "$dst/release_notes.json"

echo "Done"
