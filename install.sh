#!/bin/bash

# KeyPass Quick Installer
# This adds keypass to your PATH so you can use it from anywhere

INSTALL_DIR="/Users/krishna.dhakal/Desktop/key-pass"
SHELL_RC="$HOME/.zshrc"

echo "╔═══════════════════════════════════════╗"
echo "║   KeyPass Quick Installer            ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Check if already installed
if grep -q "keypass" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️  KeyPass already in PATH"
    echo ""
    echo "Current installation:"
    grep "keypass" "$SHELL_RC"
    echo ""
    read -p "Reinstall? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Cancelled"
        exit 0
    fi
    # Remove old entry
    grep -v "keypass" "$SHELL_RC" > "$SHELL_RC.tmp"
    mv "$SHELL_RC.tmp" "$SHELL_RC"
fi

# Add to PATH
echo "" >> "$SHELL_RC"
echo "# KeyPass - Quick Password Manager" >> "$SHELL_RC"
echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
echo "alias kp='keypass'  # Optional: shorter alias" >> "$SHELL_RC"

echo "✓ Added to $SHELL_RC"
echo ""
echo "═════════════════════════════════════════"
echo " Installation Complete!"
echo "═════════════════════════════════════════"
echo ""
echo "Reload your shell:"
echo "  source ~/.zshrc"
echo ""
echo "Then use:"
echo "  keypass github      # Search and copy password"
echo "  keypass add         # Add new password"
echo "  keypass list        # List all passwords"
echo "  kp github           # Short alias"
echo ""
echo "Your passwords are encrypted at:"
echo "  ~/Library/Application Support/KeyPass/vault.enc"
echo ""
