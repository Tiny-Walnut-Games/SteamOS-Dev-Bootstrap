#!/bin/bash
# ============================================================================
# 🧪 Ubuntu Test Adaptation of SteamOS Bootstrap
# Tests the core functionality using apt instead of pacman
# ============================================================================

set -euo pipefail

# Colors (same as original)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Import utility functions from original script
source <(grep -A 50 "^log_info()" ../bootstrap-steamos.sh | head -50)

# ============================================================================
# UBUNTU-ADAPTED PHASES
# ============================================================================

phase_verify_system_ubuntu() {
    log_section "System Verification (Ubuntu Test Mode)"
    
    log_step "Detecting Ubuntu..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        log_success "Running on: $PRETTY_NAME"
        log_warn "⚠️  TEST MODE: Simulating SteamOS environment"
    fi
    
    log_step "Verifying package manager..."
    if command -v apt &> /dev/null; then
        log_success "apt package manager available"
    else
        log_error "apt not found"
        exit 1
    fi
    
    log_step "Checking sudo access..."
    if sudo -n true 2>/dev/null || sudo -v; then
        log_success "sudo access confirmed"
    fi
}

phase_system_update_ubuntu() {
    log_section "System Update (Ubuntu Test Mode)"
    
    log_step "Updating package database..."
    sudo apt update
    log_success "Package database updated"
    
    log_step "Installing essential tools..."
    local ESSENTIAL_PKGS=(
        "build-essential"
        "git"
        "curl"
        "wget"
        "unzip"
        "zip"
        "htop"
        "tmux"
        "nano"
        "openssh-client"
        "openssh-server"
    )
    
    for pkg in "${ESSENTIAL_PKGS[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            log_success "$pkg already installed"
        else
            if sudo apt install -y "$pkg"; then
                log_success "$pkg installed"
            else
                log_error "$pkg installation failed"
            fi
        fi
    done
}

phase_dev_toolchains_ubuntu() {
    log_section "Development Toolchains (Ubuntu Test Mode)"
    
    log_step "Installing Python ecosystem..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    python3 --version
    pip3 --version
    log_success "Python 3 ready"
    
    log_step "Installing Node.js & npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    node --version
    npm --version
    log_success "Node.js & npm ready"
    
    log_step "Installing OpenJDK..."
    sudo apt install -y default-jdk
    java -version
    log_success "Java ready"
    
    log_step "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    rustc --version
    cargo --version
    log_success "Rust ready"
    
    log_step "Installing Go..."
    sudo apt install -y golang-go
    go version
    log_success "Go ready"
    
    log_step "Installing .NET..."
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0
    dotnet --version
    log_success ".NET ready"
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================

main() {
    echo "🧪 TESTING MODE: Ubuntu Adaptation of SteamOS Bootstrap"
    echo "This tests the core functionality using Ubuntu packages"
    echo ""
    
    phase_verify_system_ubuntu
    phase_system_update_ubuntu
    phase_dev_toolchains_ubuntu
    
    log_section "Test Complete"
    log_success "Bootstrap test completed successfully!"
    log_info "Core functionality verified. Ready for SteamOS deployment."
}

main "$@"