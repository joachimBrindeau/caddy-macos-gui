# Caddy GUI

A clean, modern GUI for managing Caddy server configurations on macOS.

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