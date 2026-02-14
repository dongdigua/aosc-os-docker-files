#!/usr/bin/bash

set -euo pipefail

VARIANT=$1
ARCH=$2
RELEASES_URL="https://releases.aosc.io/manifest/recipe.json"

echo "Checking for variant: ${VARIANT}, architecture: ${ARCH}"

MANIFEST=$(curl -s "$RELEASES_URL")

LATEST_RELEASE=$(echo "$MANIFEST" | jq --arg variant "$VARIANT" --arg arch "${ARCH}" '
  [.variants[] |
   select(.name == $variant) |
   .tarballs[] |
   select(.arch == $arch) |
   select(.date != null)] |
  sort_by(.date) |
  last
')

if [ "$LATEST_RELEASE" = "null" ] || [ -z "$LATEST_RELEASE" ]; then
  echo "No release found for variant: ${VARIANT}, arch: ${ARCH}}"
  echo "found=false" >> $GITHUB_OUTPUT
  exit 1
fi

DATE=$(echo "$LATEST_RELEASE" | jq -r '.date')
TARBALL_PATH=$(echo "$LATEST_RELEASE" | jq -r '.path')
SHA256SUM=$(echo "$LATEST_RELEASE" | jq -r '.sha256sum')

echo "Found release: $DATE"
echo "Tarball path: $TARBALL_PATH"

echo "found=true" >> $GITHUB_OUTPUT
echo "date=${DATE}" >> $GITHUB_OUTPUT
echo "tarball_path=${TARBALL_PATH}" >> $GITHUB_OUTPUT
echo "sha256sum=${SHA256SUM}" >> $GITHUB_OUTPUT
