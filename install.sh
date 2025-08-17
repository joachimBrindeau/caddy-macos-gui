#!/bin/bash

# Caddy GUI Homebrew Installer
# This script installs Caddy GUI using Homebrew

set -e

echo "================================"
echo "  Caddy GUI Installer"
echo "================================"
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo ""
    echo "Install Homebrew first with:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo "✅ Homebrew is installed"
echo ""

# Download the cask file to a temporary location
TEMP_CASK="/tmp/caddy-gui.rb"
echo "📥 Downloading Caddy GUI cask formula..."
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/caddy-gui.rb -o "$TEMP_CASK"

# Install using the downloaded cask file
echo "📦 Installing Caddy GUI..."
brew install --cask "$TEMP_CASK"

# Clean up
rm -f "$TEMP_CASK"

echo ""
echo "✅ Caddy GUI installed successfully!"
echo "📂 Location: /Applications/Caddy GUI.app"
echo ""
echo "You can now:"
echo "• Launch Caddy GUI from Applications or Spotlight"
echo "• Update with: brew upgrade caddy-gui"
echo "• Uninstall with: brew uninstall caddy-gui"