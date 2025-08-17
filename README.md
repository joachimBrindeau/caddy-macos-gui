# Caddy GUI

A clean, modern GUI for managing Caddy server configurations on macOS.

## ⚠️ Important: Installation Instructions

Due to the app not being signed with an Apple Developer certificate, macOS will show a "damaged app" warning. This is a security feature, not an actual problem with the app.

### Quick Install (Recommended)

```bash
# Download and run the installer script
curl -sSL https://raw.githubusercontent.com/joachimBrindeau/caddy-macos-gui/main/install-caddy-gui.sh | bash
```

### Manual Install

1. Download the DMG from [Releases](https://github.com/joachimBrindeau/caddy-macos-gui/releases)
2. Mount the DMG and copy to Applications
3. Fix the security warning:
   ```bash
   xattr -cr "/Applications/Caddy GUI.app"
   ```
4. Open the app normally

### Alternative: Build from Source

```bash
git clone https://github.com/joachimBrindeau/caddy-macos-gui.git
cd caddy-macos-gui
npm install
npm run tauri:build
./sign-app-local.sh
open "src-tauri/target/release/bundle/macos/Caddy GUI.app"
```

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
- 📦 Caddy installation manager
- ✏️ Easy domain and port configuration
- 🔀 Enable/disable sites with one click

## Development

```bash
# Install dependencies
npm install

# Run in development mode
npm run tauri dev

# Build for production
npm run tauri build
```

## Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Rust + Tauri v2
- **UI Components**: shadcn/ui

## Requirements

- macOS 10.15+
- Node.js 18+
- Rust 1.70+

## License

MIT