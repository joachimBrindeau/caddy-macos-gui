# Caddy GUI

A clean, modern GUI for managing Caddy server configurations on macOS.

## Installation

### Step 1: Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Install Caddy GUI

```bash
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/install.sh | bash
```

## Features

- 🎯 Simple site management interface for Caddy
- 🔄 Live reload configuration
- 🎨 Dark/Light theme support
- 🚀 System tray integration
- ⚙️ Auto-start on login
- 📦 Caddy installation manager
- ✏️ Easy domain and port configuration
- 🔀 Enable/disable sites with one click

## Usage

1. Launch Caddy GUI from Applications
2. Click "Install Caddy" in Settings if needed
3. Add sites using the + button
4. Access your sites at `https://[name].test`

## Update

```bash
brew upgrade caddy-gui
```

## Uninstall

```bash
brew uninstall caddy-gui
```

## License

MIT