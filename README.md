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

That's it! Caddy GUI is now installed and ready to use. No Gatekeeper warnings, no manual fixes needed.

## Screenshots

![Main Interface](docs/screenshots/main.png)
*Simple and clean interface for managing Caddy sites*

![Settings](docs/screenshots/settings.png)
*Configure system tray, dock visibility, and startup options*

## Features

- 🎯 Simple site management interface for Caddy
- 🔄 Live reload configuration
- 🎨 Dark/Light theme support
- 🚀 System tray integration
- ⚙️ Auto-start on login
- 📦 Caddy installation manager (installs Caddy server if needed)
- ✏️ Easy domain and port configuration
- 🔀 Enable/disable sites with one click
- 🔒 Security-focused: Caddy can only be installed, not uninstalled

## Usage

1. **Launch the app** from Applications or Spotlight
2. **Install Caddy** (if not already installed) by clicking "Install Caddy" in Settings
3. **Add sites** using the + button
4. **Access your sites** at `https://[name].test`

## Updating

```bash
brew upgrade caddy-gui
```

## Uninstalling

```bash
brew uninstall caddy-gui
```

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/joachimBrindeau/caddy-macos-gui.git
cd caddy-macos-gui

# Install dependencies
npm install

# Run in development mode
npm run tauri:dev

# Build for production
npm run tauri:build
```

### Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Rust + Tauri v2
- **UI Components**: shadcn/ui
- **Distribution**: Homebrew

### Requirements for Development

- macOS 11.0+
- Node.js 18+
- Rust 1.70+
- Xcode Command Line Tools

## Why Homebrew?

We use Homebrew for distribution because:
- ✅ **No security warnings** - Homebrew handles quarantine attributes automatically
- ✅ **Trusted by developers** - Standard macOS package manager
- ✅ **Easy updates** - Simple `brew upgrade` command
- ✅ **Clean uninstall** - Properly removes all app files

## License

MIT

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Support

If you encounter any issues, please [open an issue](https://github.com/joachimBrindeau/caddy-macos-gui/issues) on GitHub.