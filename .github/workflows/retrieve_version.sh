#!/bin/bash

set -e

# get version
VERSION=$(jq -r '.ym.version' ./utility/version_info.json)
release_name="Beta $VERSION"
tag_name="v$VERSION"

#write variables to github env
echo "VERSION=$VERSION" >> $GITHUB_ENV
echo "release_name=$release_name" >> $GITHUB_ENV
echo "tag_name=$tag_name" >> $GITHUB_ENV