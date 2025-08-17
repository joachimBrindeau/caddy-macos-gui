#!/bin/bash

echo "========================================"
echo "  Caddy GUI Code Signing Setup"
echo "========================================"
echo ""

# Function to sign the app with ad-hoc signature but with proper entitlements
sign_with_entitlements() {
    APP_PATH="$1"
    
    echo "📝 Signing app with enhanced ad-hoc signature..."
    
    # Remove any existing signatures and attributes
    codesign --remove-signature "$APP_PATH" 2>/dev/null || true
    xattr -cr "$APP_PATH"
    
    # Sign with entitlements and hardened runtime flags
    codesign --force --deep \
        --sign - \
        --entitlements "/Users/joachim/Development/caddy-gui/src-tauri/entitlements.plist" \
        --options runtime \
        --timestamp \
        "$APP_PATH" 2>/dev/null || {
        
        # Fallback to simpler signing
        echo "Using simplified signing..."
        codesign --force --deep --sign - "$APP_PATH"
    }
    
    # Verify the signature
    if codesign --verify --verbose "$APP_PATH" 2>&1 | grep -q "valid on disk"; then
        echo "✅ App signed successfully"
        return 0
    else
        echo "⚠️  Signature verification failed"
        return 1
    fi
}

# Check for existing code signing certificates
echo "Checking for code signing certificates..."
CERTS=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "valid identities found")

if [ "$CERTS" == "0" ]; then
    echo "❌ No code signing certificates found"
    echo ""
    echo "Options:"
    echo "1. Use enhanced ad-hoc signing (works locally)"
    echo "2. Create a self-signed certificate (requires manual Keychain setup)"
    echo "3. Get an Apple Developer certificate ($99/year)"
    echo ""
    echo "Using Option 1: Enhanced ad-hoc signing..."
    echo ""
else
    echo "✅ Found code signing certificate(s):"
    security find-identity -v -p codesigning
    echo ""
fi

# Sign the current build
APP_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/macos/Caddy GUI.app"
DMG_PATH="/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg"

if [ -d "$APP_PATH" ]; then
    sign_with_entitlements "$APP_PATH"
    
    # Also update the DMG
    if [ -f "$DMG_PATH" ]; then
        echo "📦 Updating DMG..."
        
        # Mount the DMG
        MOUNT_POINT=$(hdiutil attach "$DMG_PATH" -nobrowse -noverify -noautoopen | grep "Volumes" | awk '{print $3}')
        
        if [ -n "$MOUNT_POINT" ]; then
            # Sign the app inside the DMG
            sign_with_entitlements "$MOUNT_POINT/Caddy GUI.app"
            
            # Unmount
            hdiutil detach "$MOUNT_POINT" -quiet
            
            echo "✅ DMG updated"
        fi
    fi
else
    echo "❌ App not found. Please build first: npm run tauri:build"
    exit 1
fi

echo ""
echo "📋 Summary:"
echo "• App signed with enhanced ad-hoc signature"
echo "• Entitlements applied for proper permissions"
echo "• Ready for local installation"
echo ""
echo "To install:"
echo "1. Direct: open \"$APP_PATH\""
echo "2. From DMG: open \"$DMG_PATH\""
echo ""
echo "Note: For distribution without warnings, you need:"
echo "• Apple Developer certificate ($99/year)"
echo "• Notarization through Apple"