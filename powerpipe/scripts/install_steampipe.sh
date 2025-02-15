#!/bin/bash
set -e

# Create local bin directory
mkdir -p ~/.local/bin

# Install latest version of Steampipe
LATEST_VERSION=$(curl -sL https://api.github.com/repos/turbot/steampipe/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to get Steampipe version"
    exit 1
fi

DOWNLOAD_URL="https://github.com/turbot/steampipe/releases/download/v${LATEST_VERSION}/steampipe_linux_amd64.tar.gz"
echo "Installing Steampipe v${LATEST_VERSION}..."

# Download and verify
curl -L -o steampipe.tar.gz "$DOWNLOAD_URL"
if ! tar tvf steampipe.tar.gz >/dev/null 2>&1; then
    echo "Downloaded file is not a valid tar.gz"
    rm -f steampipe.tar.gz
    exit 1
fi

# Extract and install
tar xzf steampipe.tar.gz
if [ ! -f "steampipe" ]; then
    echo "Steampipe binary not found in archive"
    rm -f steampipe.tar.gz
    exit 1
fi

chmod +x steampipe
mv steampipe ~/.local/bin/
rm -f steampipe.tar.gz

# Verify installation
if ! ~/.local/bin/steampipe --version; then
    echo "Steampipe installation failed"
    exit 1
fi
