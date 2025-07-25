#!/bin/bash
set -e

# Input dari GitHub Actions
FORMATTED_BRANCH="$1"

echo "[*] Using branch: $FORMATTED_BRANCH"
MANIFEST_URL="https://android.googlesource.com/kernel/manifest/+/refs/heads/common-${FORMATTED_BRANCH}/default.xml?format=TEXT"

# Download manifest
aria2c -s16 -x16 -k1M -o default.xml "$MANIFEST_URL"

# Decode base64
base64 -d default.xml > manifest.xml

mkdir -p kernel_repos && cd kernel_repos

echo "[*] Cloning repos from manifest..."
grep "<project" ../manifest.xml | while read -r line; do
  name=$(echo "$line" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
  path=$(echo "$line" | sed -n 's/.*path="\([^"]*\)".*/\1/p')
  revision=$(echo "$line" | sed -n 's/.*revision="\([^"]*\)".*/\1/p')

  [ -z "$path" ] && path="$name"

  echo "[+] Cloning $name into $path ..."
  git clone --depth=1 https://android.googlesource.com/${name} ${path}
done
