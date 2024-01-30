#!/bin/bash

mkdir -p ./tmp

# loading json from file https://music-desktop-application.s3.yandex.net/stable/download.json
curl -s https://music-desktop-application.s3.yandex.net/stable/download.json > ./tmp/download.json

exe_link=$(jq -r '.windows' ./tmp/download.json)
version=$(echo $exe_link | grep -oP '(?<=x64_).*(?=.exe)')
exe_name=$(basename $exe_link)

echo "Windows url: $exe_link"
echo "Version: $version"
echo "Exe name: $exe_name"

curl $exe_link > ./tmp/$exe_name

exe_sha256=$(sha256sum ./tmp/$exe_name | awk '{print $1}')

echo "Exe sha256: $exe_sha256"

rm -rf ./version_info.json

echo "{
    \"version\": \"$version\",
    \"exe_name\": \"$exe_name\",
    \"exe_link\": \"$exe_link\",
    \"exe_sha256\": \"$exe_sha256\"
}" > ./version_info.json

rm -rf ./PKGBUILD
cp ./templates/PKGBUILD ./PKGBUILD

sed -i "s#%version%#$version#g" ./PKGBUILD
sed -i "s#%release%#1#g" ./PKGBUILD
sed -i "s#%exe_name%#$exe_name#g" ./PKGBUILD
sed -i "s#%exe_link%#$exe_link#g" ./PKGBUILD
sed -i "s#%exe_sha256%#$exe_sha256#g" ./PKGBUILD

rm -rf ./tmp