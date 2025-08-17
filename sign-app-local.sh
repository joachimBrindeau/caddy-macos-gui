#!/bin/bash

echo "Signing app for local development (bypassing Gatekeeper)..."

APP_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/macos/Caddy GUI.app"
DMG_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg"

# Remove quarantine attributes from the app
echo "Removing quarantine attributes..."
xattr -cr "$APP_PATH"

# Force re-sign with ad-hoc signature
echo "Re-signing app with ad-hoc signature..."
codesign --force --deep --sign - "$APP_PATH"

# Verify the signature
echo "Verifying signature..."
codesign --verify --verbose "$APP_PATH"

# Remove quarantine from DMG if it exists
if [ -f "$DMG_PATH" ]; then
    echo "Removing quarantine from DMG..."
    xattr -d com.apple.quarantine "$DMG_PATH" 2>/dev/null || true
fi

echo ""
echo "✅ App signed for local use. To install:"
echo "1. Open the .app directly from: $APP_PATH"
echo "2. Or rebuild the DMG: npm run tauri:build"
echo ""
echo "Note: Users downloading the app will still see the 'damaged' warning"
echo "unless the app is properly signed with an Apple Developer certificate."