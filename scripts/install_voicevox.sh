#!/bin/bash

# Aesthetic color tokens (Tokyonight / Catppuccin inspired)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🎙️  Installing VOICEVOX...${NC}"

# Target directory for extraction & desktop entry
INSTALL_DIR="$HOME/.local/share/voicebox"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$DESKTOP_DIR"

# Fetch latest release tag from GitHub API
echo -e "${BLUE}🔍 Fetching latest version from GitHub...${NC}"
LATEST_TAG=$(curl -s https://api.github.com/repos/VOICEVOX/voicevox/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}❌ Error: Could not fetch latest release tag for VOICEVOX.${NC}"
    exit 1
fi

echo -e "${GREEN}✨ Found latest VOICEVOX release:${NC} ${CYAN}v${LATEST_TAG}${NC}"

TAR_NAME="voicevox-linux-cpu-x64-${LATEST_TAG}.tar.gz"
DOWNLOAD_URL="https://github.com/VOICEVOX/voicevox/releases/download/${LATEST_TAG}/${TAR_NAME}"

CACHE_DIR="$HOME/.cache/voicevox"
mkdir -p "$CACHE_DIR"
TARGET_FILE="$CACHE_DIR/$TAR_NAME"

echo -e "${BLUE}📦 Downloading ${TAR_NAME}...${NC}"

python3 - "$DOWNLOAD_URL" "$TARGET_FILE" << 'PYEOF'
import sys, urllib.request, time, os

url = sys.argv[1]
output_file = sys.argv[2]

def format_size(bytes_num):
    if bytes_num >= 1024**3:
        return f"{bytes_num / (1024**3):.2f} GB"
    elif bytes_num >= 1024**2:
        return f"{bytes_num / (1024**2):.1f} MB"
    elif bytes_num >= 1024:
        return f"{bytes_num / 1024:.0f} KB"
    return f"{bytes_num} B"

existing_size = os.path.getsize(output_file) if os.path.exists(output_file) else 0

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
if existing_size > 0:
    req.add_header('Range', f'bytes={existing_size}-')

try:
    with urllib.request.urlopen(req) as response:
        code = response.getcode()
        
        # Determine total size
        if code == 206: # Partial Content (Resume success)
            content_range = response.headers.get('Content-Range', '')
            total_size = int(content_range.split('/')[-1]) if '/' in content_range else existing_size + int(response.headers.get('Content-Length', 0))
            mode = 'ab'
            downloaded = existing_size
        else: # Fresh download
            total_size = int(response.headers.get('Content-Length', 0))
            mode = 'wb'
            downloaded = 0
            existing_size = 0

        if existing_size > 0 and downloaded == total_size:
            print(f"  \033[32m✔ File already complete in cache ({format_size(total_size)}).\033[0m")
            sys.exit(0)

        start_time = time.time()
        last_update = 0
        bar_length = 30
        color_cyan, color_green, color_dim, color_bold, color_reset = "\033[36m", "\033[32m", "\033[2m", "\033[1m", "\033[0m"

        with open(output_file, mode) as out:
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
                    speed = (downloaded - existing_size) / elapsed if elapsed > 0 else 0
                    percent = (downloaded / total_size) * 100 if total_size > 0 else 0
                    filled_len = int(bar_length * downloaded // total_size) if total_size > 0 else 0
                    bar = '━' * filled_len + color_dim + '━' * (bar_length - filled_len) + color_reset
                    
                    sys.stdout.write(f"\r\033[K  {color_green}⠋{color_reset} [{color_cyan}{bar}{color_reset}] {color_bold}{percent:5.1f}%{color_reset}  ({format_size(downloaded)} / {format_size(total_size)})  {color_cyan}{format_size(speed)}/s{color_reset}")
                    sys.stdout.flush()

        sys.stdout.write("\n")
except urllib.error.HTTPError as e:
    if e.code == 416: # Range Not Satisfiable -> file fully downloaded
        print("  \033[32m✔ Cached file complete.\033[0m")
    else:
        raise e
PYEOF

if [ ! -f "$TARGET_FILE" ] || [ ! -s "$TARGET_FILE" ]; then
    echo -e "${RED}❌ Error: Download failed!${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Extract and install to ~/.local/share/voicebox
echo -e "${BLUE}📂 Extracting archive to ${INSTALL_DIR}...${NC}"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TARGET_FILE" -C "$INSTALL_DIR" --strip-components=1
rm -rf "$TMP_DIR"

# Create Desktop entry
DESKTOP_FILE="$DESKTOP_DIR/voicevox.desktop"
echo -e "${BLUE}📝 Creating desktop application launcher...${NC}"
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=VOICEVOX
Comment=Voice Synthesis Engine
Exec=${INSTALL_DIR}/voicevox
Icon=audio-headphones
Terminal=false
Type=Application
Categories=Audio;AudioVideo;
EOF

chmod +x "$DESKTOP_FILE"
echo -e "${GREEN}🎉 VOICEVOX v${LATEST_TAG} installed successfully!${NC}"
