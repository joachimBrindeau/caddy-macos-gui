#!/bin/bash
# Caddy GUI Installer
set -e

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo "Install it first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

TEMP_CASK="/tmp/caddy-gui-$$.rb"
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/caddy-gui.rb -o "$TEMP_CASK"
brew install --cask "$TEMP_CASK"
rm -f "$TEMP_CASK"
echo "✅ Caddy GUI installed successfully!"