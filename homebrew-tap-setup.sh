#!/bin/bash

# Script to set up a Homebrew tap for Caddy GUI distribution
echo "========================================"
echo "  Homebrew Tap Setup for Caddy GUI"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the SHA256 of the current DMG
DMG_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg"

if [ ! -f "$DMG_PATH" ]; then
    echo "❌ DMG not found. Please build first: npm run tauri:build"
    exit 1
fi

SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "DMG SHA256: $SHA256"
echo ""

# Create the Cask formula
cat > caddy-gui.rb << EOF
cask "caddy-gui" do
  version "1.0.0"
  sha256 "$SHA256"

  url "https://github.com/joachimBrindeau/caddy-macos-gui/releases/download/v#{version}/Caddy.GUI_#{version}_aarch64.dmg"
  name "Caddy GUI"
  desc "A clean, modern GUI for managing Caddy server configurations on macOS"
  homepage "https://github.com/joachimBrindeau/caddy-macos-gui"

  # Specify minimum macOS version
  depends_on macos: ">= :big_sur"

  app "Caddy GUI.app"

  # Post-install: Remove quarantine
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Caddy GUI.app"],
                   sudo: false
  end

  # Uninstall: Clean up app data
  zap trash: [
    "~/Library/Application Support/com.joachim.caddy-gui",
    "~/Library/Preferences/com.joachim.caddy-gui.plist",
    "~/Library/Saved Application State/com.joachim.caddy-gui.savedState",
    "~/.caddy-gui",
    "~/caddy/Caddyfile",
  ]
end
EOF

echo -e "${GREEN}✅ Homebrew Cask formula created: caddy-gui.rb${NC}"
echo ""
echo "To set up your Homebrew tap:"
echo ""
echo -e "${YELLOW}1. Create a new GitHub repository:${NC}"
echo "   Name: homebrew-caddy-gui"
echo "   URL: https://github.com/joachimBrindeau/homebrew-caddy-gui"
echo ""
echo -e "${YELLOW}2. Create directory structure:${NC}"
echo "   mkdir -p Casks"
echo "   mv caddy-gui.rb Casks/"
echo ""
echo -e "${YELLOW}3. Push to GitHub:${NC}"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial Caddy GUI cask'"
echo "   git remote add origin https://github.com/joachimBrindeau/homebrew-caddy-gui.git"
echo "   git push -u origin main"
echo ""
echo -e "${YELLOW}4. Users can then install with:${NC}"
echo "   brew tap joachimBrindeau/caddy-gui"
echo "   brew install --cask caddy-gui"
echo ""
echo -e "${GREEN}Benefits:${NC}"
echo "• No Gatekeeper warnings after installation"
echo "• Automatic quarantine removal"
echo "• Easy updates with 'brew upgrade caddy-gui'"
echo "• Professional distribution method"
echo "• Trusted by the developer community"