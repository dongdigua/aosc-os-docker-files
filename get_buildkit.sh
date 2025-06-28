#!/usr/bin/env bash

set -euo pipefail

function get_buildkit() {
  if [[ "x$1" == 'x' ]]; then
    echo 'provide ARCH pls'
    exit 1
  fi

  OUTPUT="$1.tar.xz"

  URL_AND_HASH=$(curl https://releases.aosc.io/manifest/recipe.json \
                   | jq --raw-output ".variants | map(select(.name==\"BuildKit\" and .retro==false)) | .[0].tarballs | map(select(.arch==\"$1\")) | sort_by(.date) | reverse .[0] | .path, .sha256sum")
  # e.g.: os-amd64/buildkit/aosc-os_buildkit_20250606_amd64.tar.xz

  {
    read -r URL_PATH
    read -r HASH
  } <<< "${URL_AND_HASH}"


  curl "https://releases.aosc.io/${URL_PATH}" -o "${OUTPUT}"

  echo "${HASH} ${OUTPUT}" | sha256sum -c -
}

#ARCHS=(amd64 arm64 riscv64 loongarch64)
ARCHS=(arm64)

for arch in "${ARCHS[@]}"
do
  get_buildkit $arch
done
