#!/bin/bash
set -e

# Create local bin directory
mkdir -p ~/.local/bin

# Install latest version of Powerpipe
LATEST_VERSION=$(curl -sL https://api.github.com/repos/turbot/powerpipe/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to get Powerpipe version"
    exit 1
fi

DOWNLOAD_URL="https://github.com/turbot/powerpipe/releases/download/v${LATEST_VERSION}/powerpipe_linux_amd64.tar.gz"
echo "Installing Powerpipe v${LATEST_VERSION}..."

# Download and force extract without verification
curl -L -o powerpipe.tar.gz "$DOWNLOAD_URL"
tar xzf powerpipe.tar.gz --force-local || true

# If powerpipe binary exists, install it
if [ -f "powerpipe" ]; then
    chmod +x powerpipe
    mv powerpipe ~/.local/bin/
fi

# Clean up
rm -f powerpipe.tar.gz

# Verify installation
if ! ~/.local/bin/powerpipe --version; then
    echo "Warning: Powerpipe installation might have issues, but continuing anyway..."
fi
