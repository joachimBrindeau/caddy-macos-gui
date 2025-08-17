#!/bin/bash

# Create a development certificate using macOS Keychain Access
echo "========================================"
echo "Creating Development Code Signing Cert"
echo "========================================"
echo ""

CERT_NAME="Caddy GUI Developer"

# Check if certificate already exists
if security find-identity -v -p codesigning | grep "$CERT_NAME" >/dev/null 2>&1; then
    echo "✅ Certificate '$CERT_NAME' already exists:"
    security find-identity -v -p codesigning | grep "$CERT_NAME"
    exit 0
fi

# Create certificate using security command
echo "Creating self-signed certificate..."
echo "This will create a certificate valid for code signing."
echo ""

# Create the certificate directly in the keychain
security create-keychain-identity \
    -c "$CERT_NAME" \
    -e "caddy-gui@local.dev" \
    -k ~/Library/Keychains/login.keychain-db \
    -p codesigning \
    -t 365 2>/dev/null || {
    
    # Fallback method: Create using certificate assistant
    echo "Trying alternative method..."
    
    # Create a certificate specification file
    cat > /tmp/cert_spec.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Name</key>
    <string>$CERT_NAME</string>
    <key>Type</key>
    <string>Code Signing</string>
    <key>IsIdentity</key>
    <true/>
    <key>KeyAlgorithm</key>
    <string>RSA</string>
    <key>KeySize</key>
    <integer>2048</integer>
    <key>CanSign</key>
    <true/>
    <key>CanEncrypt</key>
    <false/>
    <key>CanDecrypt</key>
    <false/>
    <key>CanDerive</key>
    <false/>
    <key>CanWrap</key>
    <false/>
    <key>CanUnwrap</key>
    <false/>
    <key>CanVerify</key>
    <true/>
    <key>KeyUsage</key>
    <array>
        <string>Sign</string>
    </array>
</dict>
</plist>
EOF

    # Use certtool to create the certificate
    certtool c k=~/Library/Keychains/login.keychain-db << EOF
$CERT_NAME
s
y
2048
365
y
b
s
y
localhost
$CERT_NAME


y
EOF
}

# Verify certificate was created
echo ""
echo "Verifying certificate..."
if security find-identity -v -p codesigning | grep -q "$CERT_NAME"; then
    echo "✅ Certificate created successfully!"
    echo ""
    security find-identity -v -p codesigning | grep "$CERT_NAME"
else
    echo "⚠️  Certificate may not be suitable for code signing"
    echo "All available certificates:"
    security find-identity -v
fi

# Clean up
rm -f /tmp/cert_spec.plist 2>/dev/null