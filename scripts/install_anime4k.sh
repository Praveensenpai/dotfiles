#!/bin/bash

# Configuration
URL="https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip"
TARGET="$HOME/.config/mpv"

echo "➜ Step 1: Ensuring $TARGET exists..."
mkdir -p "$TARGET"

echo "➜ Step 2: Entering /tmp for a clean workspace..."
cd /tmp || exit

echo "➜ Step 3: Fetching Anime4K shaders..."
wget -q --show-progress "$URL" -O Anime4K.zip

echo "➜ Step 4: Extracting archive..."
unzip -o Anime4K.zip > /dev/null

echo "➜ Step 5: Moving shaders folder..."
mv -v shaders/ "$TARGET/"

echo "➜ Step 6: Moving configuration files..."
mv -v input.conf "$TARGET/"
mv -v mpv.conf "$TARGET/"

echo "➜ Step 7: Removing temporary junk..."
rm -rf Anime4K.zip __MACOSX

echo "➜ Success: Anime4K is ready for mpv."