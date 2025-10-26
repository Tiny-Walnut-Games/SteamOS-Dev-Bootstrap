#!/bin/bash
# ============================================================================
# 🪟 WSL2 Test Setup for SteamOS Bootstrap
# Run this in any WSL2 distribution to prepare for testing
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

echo "🪟 Setting up WSL2 for SteamOS Bootstrap Testing"
echo "================================================"

# Check if we're in WSL
if [[ ! $(uname -r) =~ microsoft|WSL ]]; then
    log_error "This script must be run in WSL2"
    exit 1
fi

log_info "WSL2 environment detected"
log_info "Distribution: $(lsb_release -d | cut -f2)" 2>/dev/null || log_info "Distribution: $(cat /etc/issue | head -1)"

# Install shellcheck for better script validation
log_info "Installing ShellCheck for script validation..."
if command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y shellcheck
    log_success "ShellCheck installed"
elif command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm shellcheck
    log_success "ShellCheck installed"
else
    log_warn "Unknown package manager - skipping ShellCheck"
fi

# Create mock SteamOS environment
log_info "Creating mock SteamOS environment..."
sudo cp /etc/os-release /etc/os-release.backup 2>/dev/null || true

# Create a temporary SteamOS os-release for testing
sudo tee /tmp/mock-steamos-release > /dev/null << 'EOF'
ID="steamos"
VERSION_ID="3.5"
PRETTY_NAME="SteamOS 3.5 (Holo)"
NAME="SteamOS"
VERSION_CODENAME="holo"
HOME_URL="https://www.steampowered.com/"
EOF

log_success "Mock SteamOS environment prepared"

log_info "Testing bootstrap script..."
# Copy the script to a test location
cp /mnt/c/Users/Jerry/RiderProjects/SteamOS-Dev-Bootstrap/bootstrap-steamos.sh /tmp/test-bootstrap.sh
chmod +x /tmp/test-bootstrap.sh

# Temporarily replace os-release for testing
sudo cp /tmp/mock-steamos-release /etc/os-release

echo ""
echo "🧪 Ready for testing!"
echo ""
echo "Run the bootstrap script with:"
echo "  /tmp/test-bootstrap.sh"
echo ""
echo "When done, restore original os-release:"
echo "  sudo cp /etc/os-release.backup /etc/os-release"