#!/usr/bin/bash

set -euo pipefail

FULL_REPO="$1"

echo "Gathering tags from artifacts..."

if [ -d "downloaded-tags" ]; then
   TAGS=$(cat downloaded-tags/*)
else
   echo "[-] No tags found via artifacts, skipping."
   exit 0
fi

echo "Found tags:"
echo "$TAGS" | sort

TAG_GROUPS=$(echo "$TAGS" | grep -Eo '^[[:alpha:]]+-[[:digit:]]{8}' | uniq)

echo "Tag groups:"
echo "$TAG_GROUPS"

# Create manifests for each group
echo "$TAG_GROUPS" | while IFS= read -r GROUP_KEY; do
  IMAGES=$(echo "$TAGS" | grep "$GROUP_KEY" | sed "s!^!$FULL_REPO:!" | tr '\n' ' ')
  if [ -n "$GROUP_KEY" ] && [ -n "$IMAGES" ]; then
    VARIANT=$(echo "$GROUP_KEY" | cut -d'-' -f1)

    VERSIONED_TAG="${GROUP_KEY}"
    SIMPLE_TAG="${VARIANT}"

    echo "Creating manifest for: ${VERSIONED_TAG}"
    echo "Images: ${IMAGES}"

    # Create versioned manifest
    if docker manifest create "${FULL_REPO}:${VERSIONED_TAG}" ${IMAGES}; then
      docker manifest push "${FULL_REPO}:${VERSIONED_TAG}"
      echo "[+] Created versioned manifest: ${VERSIONED_TAG}"
    else
      echo "[x] Failed to create versioned manifest: ${VERSIONED_TAG}"
      exit 1
    fi

    # Create or update simple variant manifest (latest for this variant)
    if docker manifest create "${FULL_REPO}:${SIMPLE_TAG}" ${IMAGES} --amend; then
      docker manifest push "${FULL_REPO}:${SIMPLE_TAG}"
      echo "[+] Updated simple manifest: ${SIMPLE_TAG}"
    else
      echo "[x] Failed to create simple manifest: ${SIMPLE_TAG}"
      exit 1
    fi

    if [ "$VARIANT" = "container" ]; then
      if docker manifest create "${FULL_REPO}:latest" ${IMAGES} --amend; then
        docker manifest push "${FULL_REPO}:latest"
        echo "[+] Updated latest manifest"
      else
        echo "[x] Failed to update latest manifest"
        exit 1
      fi
    fi
  fi
done

echo "Manifest creation completed"
