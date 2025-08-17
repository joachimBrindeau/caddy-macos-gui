#!/bin/bash

# Script to publish DMG to GitHub release for Homebrew distribution

echo "================================"
echo "  Publish Release for Homebrew"
echo "================================"
echo ""

DMG_PATH="src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg"

# Check if DMG exists
if [ ! -f "$DMG_PATH" ]; then
    echo "❌ DMG not found at: $DMG_PATH"
    echo "Run 'npm run tauri:build' first"
    exit 1
fi

# Get SHA256
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "📦 DMG found: $DMG_PATH"
echo "🔒 SHA256: $SHA256"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not installed. To publish manually:"
    echo ""
    echo "1. Go to: https://github.com/joachimBrindeau/caddy-macos-gui/releases/edit/v1.0.0"
    echo "2. Upload the DMG file from: $DMG_PATH"
    echo "3. Update the release notes"
    echo ""
    echo "Or install GitHub CLI:"
    echo "brew install gh"
    echo "gh auth login"
    exit 0
fi

# Check if authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

echo "📤 Uploading DMG to GitHub release..."

# Upload the DMG to the release
gh release upload v1.0.0 "$DMG_PATH" \
    --repo joachimBrindeau/caddy-macos-gui \
    --clobber

if [ $? -eq 0 ]; then
    echo "✅ DMG uploaded successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Update caddy-gui.rb with new SHA256: $SHA256"
    echo "2. Commit and push changes"
    echo "3. Users can install with: curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/install.sh | bash"
else
    echo "❌ Failed to upload DMG"
fi