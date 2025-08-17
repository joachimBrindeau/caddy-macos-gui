# Installation Guide

## Homebrew Installation (Recommended)

Caddy GUI is distributed exclusively through Homebrew for the best user experience.

### Why Homebrew?

- ✅ **No security warnings** - Automatic quarantine removal
- ✅ **Trusted distribution** - Standard macOS package manager
- ✅ **Easy updates** - Simple `brew upgrade` command
- ✅ **Clean uninstall** - Proper cleanup of all files
- ✅ **No manual fixes** - Works immediately after installation

### Installation Steps

#### Step 1: Install Homebrew

If you don't have Homebrew installed, install it first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Step 2: Install Caddy GUI

```bash
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/caddy-gui.rb | brew install --cask /dev/stdin
```

### Common Commands

**Update Caddy GUI:**
```bash
brew upgrade caddy-gui
```

**Uninstall Caddy GUI:**
```bash
brew uninstall caddy-gui
```

**Reinstall Caddy GUI:**
```bash
brew reinstall caddy-gui
```

### Troubleshooting

If you encounter any issues:

1. **Ensure Homebrew is up to date:**
   ```bash
   brew update
   ```

2. **Check for conflicts:**
   ```bash
   brew doctor
   ```

3. **Force reinstall if needed:**
   ```bash
   brew uninstall --force caddy-gui
   curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/caddy-gui.rb | brew install --cask /dev/stdin
   ```

### Building from Source

If you prefer to build from source for development:

```bash
git clone https://github.com/joachimBrindeau/caddy-macos-gui.git
cd caddy-macos-gui
npm install
npm run tauri:dev  # For development
npm run tauri:build # For production build
```

## Notes

- The DMG file is automatically downloaded from GitHub releases during installation
- Homebrew handles all code signing and Gatekeeper issues
- No Apple Developer certificate is required for users
- The app will auto-update through Homebrew