# macOS Code Signing & Distribution Guide

## The "Damaged App" Issue

When users download the app, macOS shows it as "damaged" because:
1. The app is not signed with an Apple Developer certificate
2. The app is not notarized by Apple
3. macOS Gatekeeper blocks unsigned apps downloaded from the internet

## Solutions

### For Local Development/Testing

Run the provided script after building:
```bash
./sign-app-local.sh
```

### For Users (Temporary Workaround)

Users can bypass Gatekeeper by:

1. **Method 1: Remove Quarantine**
   ```bash
   xattr -cr "/Applications/Caddy GUI.app"
   ```

2. **Method 2: Right-click Open**
   - Right-click the app
   - Select "Open"
   - Click "Open" in the warning dialog

3. **Method 3: Terminal**
   ```bash
   sudo spctl --master-disable  # Disable Gatekeeper temporarily
   # Install the app
   sudo spctl --master-enable   # Re-enable Gatekeeper
   ```

### Permanent Solution (Requires Apple Developer Account)

1. **Get an Apple Developer Account** ($99/year)
   - Sign up at https://developer.apple.com

2. **Create signing certificates**
   ```bash
   # After enrolling in Apple Developer Program
   security find-identity -v -p codesigning
   ```

3. **Update tauri.conf.json**
   ```json
   "macOS": {
     "signingIdentity": "Developer ID Application: Your Name (TEAMID)",
     "hardenedRuntime": true
   }
   ```

4. **Build and Sign**
   ```bash
   npm run tauri:build
   ```

5. **Notarize the app**
   ```bash
   xcrun notarytool submit "Caddy GUI_1.0.0_aarch64.dmg" \
     --apple-id "your@email.com" \
     --password "app-specific-password" \
     --team-id "TEAMID" \
     --wait
   ```

## Current Status

The app is currently:
- ✅ Built successfully
- ✅ Ad-hoc signed (self-signed)
- ❌ Not signed with Developer ID
- ❌ Not notarized

This means:
- ✅ Works when built locally
- ⚠️ Shows "damaged" when downloaded
- ✅ Can be fixed with workarounds above