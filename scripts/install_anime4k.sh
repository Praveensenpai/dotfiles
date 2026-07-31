#!/bin/bash

# Configuration
URL="https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip"
TARGET="$HOME/.config/mpv"

# Check dependencies
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q --show-progress -O Anime4K.zip"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -L --progress-bar -o Anime4K.zip"
else
    echo "❌ Error: Neither wget nor curl is installed!"
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "❌ Error: unzip is not installed!"
    exit 1
fi

echo "➜ Step 1: Ensuring $TARGET exists..."
mkdir -p "$TARGET"

echo "➜ Step 2: Entering /tmp for a clean workspace..."
cd /tmp || exit 1

echo "➜ Step 3: Fetching Anime4K shaders..."
$DOWNLOAD_CMD "$URL"

if [ ! -f Anime4K.zip ]; then
    echo "❌ Download failed!"
    exit 1
fi

echo "➜ Step 4: Extracting archive..."
unzip -o Anime4K.zip > /dev/null

echo "➜ Step 5: Moving shaders folder..."
mv -v shaders/ "$TARGET/"

echo "➜ Step 6: Moving configuration files..."
mv -v input.conf "$TARGET/"
mv -v mpv.conf "$TARGET/"

echo "➜ Step 6b: Setting Mode C + A as default in mpv.conf..."
sed -i 's|^# glsl-shaders=.*|glsl-shaders="~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"|' "$TARGET/mpv.conf"


echo "➜ Step 7: Removing temporary junk..."
rm -rf Anime4K.zip __MACOSX

echo "➜ Success: Anime4K is ready for mpv."