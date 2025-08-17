#!/bin/bash

# Script to update the v1.0.0 release with the new DMG

echo "This script will help you update the v1.0.0 release on GitHub"
echo "============================================================"
echo ""

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo "First, you need to authenticate with GitHub CLI."
    echo "Please run: gh auth login"
    echo "Then run this script again."
    exit 1
fi

echo "Step 1: Deleting existing v1.0.0 release..."
gh release delete v1.0.0 --yes --repo joachimBrindeau/caddy-macos-gui

echo ""
echo "Step 2: Creating new v1.0.0 release with updated DMG..."

# Create the release with the new DMG
gh release create v1.0.0 \
  --title "Caddy GUI v1.0.0 - Initial Release" \
  --notes "# 🎉 Caddy GUI v1.0.0 - Initial Release

A clean, modern GUI for managing Caddy server configurations on macOS.

## ✨ Features

- **🚀 One-Click Caddy Installation** - Install Caddy server directly from the app
- **🌐 Site Management** - Easily manage local development sites with .test domains
- **🔄 Live Configuration** - Enable/disable sites without editing configuration files
- **📍 System Tray Support** - Quick access from your menu bar
- **🎨 Theme Support** - Beautiful dark and light themes
- **⚡ Auto-Start** - Launch automatically on system boot
- **✏️ Real-time Editing** - Edit site configurations on the fly

## 🔒 Security Features

- Installation-only design (no uninstall functionality for security)
- Clean codebase with minimal dependencies
- Native macOS integration

## 📋 Requirements

- macOS 11.0 or later
- Homebrew (for Caddy installation)

## 🚀 Getting Started

1. Download and install the app from the DMG file below
2. Click \"Install Caddy\" if not already installed
3. Add your first site with the + button
4. Your sites will be available at https://[name].test

## 📝 Notes

This release focuses on simplicity and security. The app intentionally only allows Caddy installation (not uninstallation) to prevent accidental removal of your web server.

## 📦 Download

Download **Caddy.GUI_1.0.0_aarch64.dmg** below for Apple Silicon Macs." \
  --repo joachimBrindeau/caddy-macos-gui \
  "/Users/joachim/Development/caddy-gui/src-tauri/target/release/bundle/dmg/Caddy GUI_1.0.0_aarch64.dmg#Caddy.GUI_1.0.0_aarch64.dmg"

echo ""
echo "✅ Release updated successfully!"
echo "View at: https://github.com/joachimBrindeau/caddy-macos-gui/releases/tag/v1.0.0"