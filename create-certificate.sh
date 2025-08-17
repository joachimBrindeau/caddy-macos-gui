#!/bin/bash

# Create a self-signed certificate for code signing
# This creates a certificate that macOS will trust for local development

echo "========================================"
echo "Creating Self-Signed Code Signing Cert"
echo "========================================"
echo ""

CERT_NAME="Caddy GUI Developer"
KEYCHAIN_NAME="login.keychain"

# Check if certificate already exists
if security find-certificate -c "$CERT_NAME" >/dev/null 2>&1; then
    echo "⚠️  Certificate '$CERT_NAME' already exists"
    read -p "Delete and recreate? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing certificate..."
        security delete-certificate -c "$CERT_NAME" 2>/dev/null || true
    else
        echo "Using existing certificate"
        security find-identity -v -p codesigning | grep "$CERT_NAME"
        exit 0
    fi
fi

# Create the certificate
echo "Creating new self-signed certificate..."

# Use OpenSSL to create certificate and key
cat > /tmp/cert_config.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[ dn ]
C = US
ST = CA
L = San Francisco
O = Caddy GUI
OU = Development
CN = $CERT_NAME

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = codeSigning
EOF

# Generate private key and certificate
openssl req -x509 -new -nodes \
    -keyout /tmp/caddy_gui_key.pem \
    -out /tmp/caddy_gui_cert.pem \
    -days 365 \
    -config /tmp/cert_config.conf 2>/dev/null

# Convert to PKCS12 format
openssl pkcs12 -export \
    -inkey /tmp/caddy_gui_key.pem \
    -in /tmp/caddy_gui_cert.pem \
    -out /tmp/caddy_gui.p12 \
    -name "$CERT_NAME" \
    -passout pass:temppass 2>/dev/null

# Import into keychain
echo "Importing certificate into keychain..."
security import /tmp/caddy_gui.p12 \
    -k ~/Library/Keychains/login.keychain-db \
    -P temppass \
    -T /usr/bin/codesign \
    -T /usr/bin/security 2>/dev/null || {
        echo "❌ Failed to import certificate"
        exit 1
    }

# Trust the certificate for code signing
echo "Setting certificate trust..."
security add-trusted-cert \
    -d \
    -r trustRoot \
    -k ~/Library/Keychains/login.keychain-db \
    /tmp/caddy_gui_cert.pem 2>/dev/null || true

# Clean up temporary files
rm -f /tmp/caddy_gui_key.pem /tmp/caddy_gui_cert.pem /tmp/caddy_gui.p12 /tmp/cert_config.conf

# Verify certificate was created
echo ""
echo "Verifying certificate..."
if security find-identity -v -p codesigning | grep "$CERT_NAME" >/dev/null 2>&1; then
    echo "✅ Certificate created successfully!"
    echo ""
    security find-identity -v -p codesigning | grep "$CERT_NAME"
    echo ""
    echo "Certificate name: $CERT_NAME"
else
    echo "❌ Certificate creation failed"
    exit 1
fi