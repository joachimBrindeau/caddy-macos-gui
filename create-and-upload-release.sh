#!/bin/bash

# Script to create GitHub release and upload DMG
# This uses gh CLI which needs to be authenticated

echo "========================================"
echo "  Creating GitHub Release with DMG"
echo "========================================"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    brew install gh
fi

# Variables
VERSION="v1.0.0"
DMG_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg"
REPO="joachimBrindeau/caddy-macos-gui"

# Check if DMG exists
if [ ! -f "$DMG_PATH" ]; then
    echo "❌ DMG not found. Building..."
    cd /Users/joachim/Development/caddy-gui
    npm run tauri:build
fi

# Get SHA256
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "📦 DMG SHA256: $SHA256"

# Release notes
NOTES="# Caddy GUI v1.0.0

## 🍺 Installation via Homebrew

**Step 1:** Install Homebrew (if needed)
\`\`\`bash
/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
\`\`\`

**Step 2:** Install Caddy GUI
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/install.sh | bash
\`\`\`

## Features

- 🎯 Simple site management for Caddy
- 🔄 Live configuration reload
- 🎨 Dark/Light theme support
- 🚀 System tray integration
- 📦 One-click Caddy installation
- 🔒 Security-focused (install-only)

## Notes

The DMG below is for Homebrew installation. Use the commands above to install."

# Check if release exists and delete if it does
echo "Checking for existing release..."
if gh release view $VERSION --repo $REPO &>/dev/null; then
    echo "Deleting existing release..."
    gh release delete $VERSION --repo $REPO --yes
fi

# Create new release with DMG
echo "Creating release and uploading DMG..."
gh release create $VERSION \
    --repo $REPO \
    --title "Caddy GUI v1.0.0" \
    --notes "$NOTES" \
    "$DMG_PATH#Caddy.GUI_1.0.0_aarch64.dmg"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Release created successfully!"
    echo "🔗 View at: https://github.com/$REPO/releases/tag/$VERSION"
    echo ""
    echo "Now users can install with:"
    echo "curl -sSL https://raw.githubusercontent.com/$REPO/main/install.sh | bash"
else
    echo "❌ Failed to create release"
    echo ""
    echo "Please run:"
    echo "1. gh auth login"
    echo "2. ./create-and-upload-release.sh"
fi