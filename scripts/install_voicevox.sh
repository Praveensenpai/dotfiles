#!/bin/bash

echo "Installing VOICEVOX..."

# Target directory for extraction & desktop entry
INSTALL_DIR="$HOME/.local/share/voicebox"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$DESKTOP_DIR"

# Fetch latest release tag from GitHub API
LATEST_TAG=$(curl -s https://api.github.com/repos/VOICEVOX/voicevox/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not fetch latest release tag for VOICEVOX."
    exit 1
fi

echo "Latest VOICEVOX version found: $LATEST_TAG"

TAR_NAME="voicevox-linux-cpu-x64-${LATEST_TAG}.tar.gz"
DOWNLOAD_URL="https://github.com/VOICEVOX/voicevox/releases/download/${LATEST_TAG}/${TAR_NAME}"

# Ensure aria2c is installed for fast multi-connection downloading
if ! command -v aria2c &>/dev/null; then
    echo "Installing aria2c for fast multi-threaded downloading..."
    sudo pacman -S --needed --noconfirm aria2c
fi

TMP_DIR=$(mktemp -d)
echo "Downloading $TAR_NAME with aria2c..."

if command -v aria2c &>/dev/null; then
    aria2c -x 8 -s 8 --summary-interval=1 -d "$TMP_DIR" -o "$TAR_NAME" "$DOWNLOAD_URL"
else
    curl -L --progress-bar "$DOWNLOAD_URL" -o "$TMP_DIR/$TAR_NAME"
fi

if [ ! -f "$TMP_DIR/$TAR_NAME" ]; then
    echo "Error: Download failed!"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Extract and install to ~/.local/share/voicebox
echo "Extracting to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_DIR/$TAR_NAME" -C "$INSTALL_DIR" --strip-components=1
rm -rf "$TMP_DIR"

# Create Desktop entry
DESKTOP_FILE="$DESKTOP_DIR/voicevox.desktop"
echo "Creating desktop entry at $DESKTOP_FILE..."
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=VOICEVOX
Comment=Voice Synthesis Engine
Exec=$INSTALL_DIR/voicevox
Icon=audio-headphones
Terminal=false
Type=Application
Categories=Audio;AudioVideo;
EOF

chmod +x "$DESKTOP_FILE"
echo "✔ VOICEVOX $LATEST_TAG installed successfully!"
