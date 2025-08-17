#!/bin/bash

# Caddy GUI Installer Script
# This script helps install Caddy GUI on macOS by handling Gatekeeper issues

set -e

echo "======================================"
echo "    Caddy GUI Installer for macOS    "
echo "======================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Function to download the app
download_app() {
    echo "📥 Downloading Caddy GUI..."
    curl -L -o ~/Downloads/Caddy_GUI.dmg \
        "https://github.com/joachimBrindeau/caddy-macos-gui/releases/download/v1.0.0/Caddy.GUI_1.0.0_aarch64.dmg"
    echo "✅ Download complete"
}

# Function to mount DMG and install
install_app() {
    echo "📦 Installing Caddy GUI..."
    
    # Mount the DMG
    hdiutil attach ~/Downloads/Caddy_GUI.dmg -nobrowse -quiet
    
    # Copy to Applications
    cp -R "/Volumes/Caddy GUI/Caddy GUI.app" /Applications/
    
    # Unmount the DMG
    hdiutil detach "/Volumes/Caddy GUI" -quiet
    
    echo "✅ App copied to Applications"
}

# Function to fix Gatekeeper issue
fix_gatekeeper() {
    echo "🔧 Fixing macOS security restrictions..."
    
    # Remove quarantine attribute
    xattr -cr "/Applications/Caddy GUI.app" 2>/dev/null || {
        echo "⚠️  Need administrator privileges to remove quarantine"
        sudo xattr -cr "/Applications/Caddy GUI.app"
    }
    
    # Re-sign with ad-hoc signature
    codesign --force --deep --sign - "/Applications/Caddy GUI.app" 2>/dev/null || true
    
    echo "✅ Security restrictions removed"
}

# Main installation flow
main() {
    echo "This installer will:"
    echo "1. Download Caddy GUI from GitHub"
    echo "2. Install it to /Applications"
    echo "3. Fix macOS Gatekeeper restrictions"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    
    # Check if already installed
    if [ -d "/Applications/Caddy GUI.app" ]; then
        echo "⚠️  Caddy GUI is already installed"
        read -p "Reinstall? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing old installation..."
            rm -rf "/Applications/Caddy GUI.app"
        else
            echo "Skipping download and install..."
            fix_gatekeeper
            echo ""
            echo "🎉 Caddy GUI is ready to use!"
            echo "📂 Location: /Applications/Caddy GUI.app"
            open "/Applications/Caddy GUI.app"
            exit 0
        fi
    fi
    
    download_app
    install_app
    fix_gatekeeper
    
    # Clean up
    rm -f ~/Downloads/Caddy_GUI.dmg
    
    echo ""
    echo "🎉 Installation complete!"
    echo "📂 Caddy GUI has been installed to /Applications"
    echo ""
    read -p "Launch Caddy GUI now? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "/Applications/Caddy GUI.app"
    fi
}

# Run main function
main