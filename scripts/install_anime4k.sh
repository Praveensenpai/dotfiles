#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

URL="https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip"
TARGET="$HOME/.config/mpv"

echo -e "${PURPLE}📺  Installing Anime4K shaders for mpv...${NC}"

if ! command -v unzip &> /dev/null; then
    echo -e "${RED}❌ Error: unzip is not installed!${NC}"
    exit 1
fi

echo -e "${BLUE}📂 Ensuring ${TARGET} exists...${NC}"
mkdir -p "$TARGET"

TMP_DIR=$(mktemp -d)
TARGET_FILE="$TMP_DIR/Anime4K.zip"

echo -e "${BLUE}📦 Downloading Anime4K GLSL package...${NC}"

python3 - "$URL" "$TARGET_FILE" << 'PYEOF'
import sys, urllib.request, time

url, output_file = sys.argv[1], sys.argv[2]

def format_size(bytes_num):
    if bytes_num >= 1024**2:
        return f"{bytes_num / (1024**2):.1f} MB"
    elif bytes_num >= 1024:
        return f"{bytes_num / 1024:.0f} KB"
    return f"{bytes_num} B"

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as response, open(output_file, 'wb') as out:
    total_size = int(response.headers.get('Content-Length', 0))
    downloaded = 0
    start_time = time.time()
    last_update = 0

    bar_length = 30
    color_cyan, color_green, color_dim, color_bold, color_reset = "\033[36m", "\033[32m", "\033[2m", "\033[1m", "\033[0m"

    while True:
        chunk = response.read(65536)
        if not chunk:
            break
        out.write(chunk)
        downloaded += len(chunk)
        now = time.time()
        if now - last_update > 0.08 or downloaded == total_size:
            last_update = now
            elapsed = now - start_time
            speed = downloaded / elapsed if elapsed > 0 else 0
            percent = (downloaded / total_size) * 100 if total_size > 0 else 0
            filled_len = int(bar_length * downloaded // total_size) if total_size > 0 else 0
            bar = '━' * filled_len + color_dim + '━' * (bar_length - filled_len) + color_reset
            sys.stdout.write(f"\r\033[K  {color_green}⠋{color_reset} [{color_cyan}{bar}{color_reset}] {color_bold}{percent:5.1f}%{color_reset}  ({format_size(downloaded)} / {format_size(total_size)})  {color_cyan}{format_size(speed)}/s{color_reset}")
            sys.stdout.flush()

sys.stdout.write("\n")
PYEOF

if [ ! -f "$TARGET_FILE" ]; then
    echo -e "${RED}❌ Download failed!${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo -e "${BLUE}📂 Extracting Anime4K shaders to ${TARGET}...${NC}"
unzip -o "$TARGET_FILE" -d "$TMP_DIR" > /dev/null

mv "$TMP_DIR"/shaders/ "$TARGET/" 2>/dev/null || true
mv "$TMP_DIR"/input.conf "$TARGET/" 2>/dev/null || true
mv "$TMP_DIR"/mpv.conf "$TARGET/" 2>/dev/null || true

sed -i 's|^# glsl-shaders=.*|glsl-shaders="~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"|' "$TARGET/mpv.conf" 2>/dev/null || true

rm -rf "$TMP_DIR"
echo -e "${GREEN}🎉 Anime4K shaders installed and configured for mpv!${NC}"