# Caddy GUI v1.0.0

## 🍺 Installation via Homebrew Only

We've simplified installation to use Homebrew exclusively for the best user experience.

### Install in 2 Steps:

**Step 1:** Install Homebrew (if needed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Step 2:** Install Caddy GUI
```bash
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/caddy-gui.rb | brew install --cask /dev/stdin
```

## ✨ Features

- 🎯 Simple site management for Caddy server
- 🔄 Live configuration reload
- 🎨 Dark/Light theme support
- 🚀 System tray integration
- ⚙️ Auto-start on login
- 📦 One-click Caddy installation
- 🔒 Security-focused (install-only design)

## 📝 Why Homebrew?

- ✅ **No security warnings** - Handles Gatekeeper automatically
- ✅ **Easy updates** - Just run `brew upgrade caddy-gui`
- ✅ **Clean uninstall** - Proper cleanup with `brew uninstall caddy-gui`
- ✅ **Trusted** - Standard macOS package manager

## 🚀 Quick Start

1. Install using the commands above
2. Launch Caddy GUI from Applications
3. Click "Install Caddy" in Settings (if needed)
4. Add your sites with the + button
5. Access at `https://[name].test`

## 📦 Note on DMG File

The DMG file below is used by Homebrew for installation. **Do not download it directly** - use the Homebrew installation commands above for the best experience.

---

**Full Changelog**: https://github.com/joachimBrindeau/caddy-macos-gui/commits/v1.0.0