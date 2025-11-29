#!/bin/bash
# One-line installer for XNoctra Pterodactyl Protection System
# Usage: bash <(curl -s https://raw.githubusercontent.com/XNoctra/pterodactyl-protections/main/one-line-install.sh)

echo "🛡️  XNoctra Pterodactyl Protection System"
echo "=========================================="
echo "📥 Downloading installer..."

# Create temp file
TEMP_FILE="/tmp/xnoctra-installer-$$.sh"

# Download main installer
if curl -s -o "$TEMP_FILE" "https://raw.githubusercontent.com/XNoctra/pterodactyl-protections/main/install.sh"; then
    chmod +x "$TEMP_FILE"
    echo "✅ Installer downloaded successfully"
    echo "🚀 Starting installation..."
    echo ""
    exec bash "$TEMP_FILE"
else
    echo "❌ Failed to download installer"
    echo "💡 Check your internet connection and try again"
    exit 1
fi