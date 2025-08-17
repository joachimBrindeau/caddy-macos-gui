#!/bin/bash

# Direct Homebrew installation without a separate tap repository
# This script allows users to install Caddy GUI directly using Homebrew

echo "Installing Caddy GUI via Homebrew..."

# Create a temporary Cask formula
TEMP_CASK="/tmp/caddy-gui.rb"

cat > "$TEMP_CASK" << 'EOF'
cask "caddy-gui" do
  version "1.0.0"
  sha256 "a053c713d624f34637f3c4a7d9ad693edc4b93fb4b03e510412495f0cd4be4dc"

  url "https://github.com/joachimBrindeau/caddy-macos-gui/releases/download/v#{version}/Caddy.GUI_#{version}_aarch64.dmg"
  name "Caddy GUI"
  desc "A clean, modern GUI for managing Caddy server configurations on macOS"
  homepage "https://github.com/joachimBrindeau/caddy-macos-gui"

  depends_on macos: ">= :big_sur"

  app "Caddy GUI.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Caddy GUI.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/com.joachim.caddy-gui",
    "~/Library/Preferences/com.joachim.caddy-gui.plist",
    "~/.caddy-gui",
    "~/caddy/Caddyfile",
  ]
end
EOF

# Install using the local Cask file
brew install --cask "$TEMP_CASK"

# Clean up
rm -f "$TEMP_CASK"

echo "✅ Caddy GUI installed successfully!"
echo "📂 Location: /Applications/Caddy GUI.app"