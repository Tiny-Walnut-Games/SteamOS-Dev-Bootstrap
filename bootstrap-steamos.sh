#!/bin/bash
# ============================================================================
# 🌲 SteamOS Development Environment Bootstrap
# For SteamOS 3.x (Holo) - First Login Ritual
# ============================================================================
# This script transforms a fresh SteamOS installation into a full development
# sanctuary, installing all essential tools, dev toolchains, and applications.
#
# Run this on first login:
#   Option 1 (Recommended): Download and verify before running
#     curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh -o bootstrap-steamos.sh
#     less bootstrap-steamos.sh  # Review the script
#     bash bootstrap-steamos.sh
#
#   Option 2: Direct execution (only if you trust the source)
#     curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh | bash
# ============================================================================

set -euo pipefail

VERSION="1.0.0"

# Colors for output (respecting terminal support)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ============================================================================
# SECURITY FUNCTIONS
# ============================================================================

# Path: scripts/security/secure_download.sh

# Validate URL before downloading
validate_url() {
  local url="$1"
  # Check for HTTPS
  if [[ ! "$url" =~ ^https:// ]]; then
    echo "ERROR: Only HTTPS URLs are allowed" >&2
    return 1
  fi
  
  # Check for known domains (add your trusted domains)
  if [[ ! "$url" =~ github\.com|githubusercontent\.com|steamdeck-packages\.steamos\.cloud|deb\.nodesource\.com|sh\.rustup\.rs|packages\.microsoft\.com ]]; then
    echo "WARNING: URL is not from a known trusted domain" >&2
    read -p "Continue anyway? (y/N): " confirm
    [[ "$confirm" == "y" || "$confirm" == "Y" ]] || return 1
  fi
  
  return 0
}

# Secure download function
secure_download() {
  local url="$1"
  local output_file="$2"
  
  # Validate URL
  validate_url "$url" || return 1
  
  # Download with proper TLS settings
  if ! curl --proto '=https' --tlsv1.2 -sSf -o "$output_file" "$url"; then
    echo "ERROR: Download failed from $url" >&2
    return 1
  fi
  
  echo "Successfully downloaded to $output_file"
  return 0
}

# Verify file checksum
verify_checksum() {
  local file="$1"
  local expected_sha256="$2"
  
  if [[ -z "$expected_sha256" ]]; then
    echo "WARNING: No checksum provided for verification" >&2
    return 0
  fi
  
  local actual_sha256
  actual_sha256=$(sha256sum "$file" | cut -d' ' -f1)
  
  if [[ "$actual_sha256" != "$expected_sha256" ]]; then
    echo "ERROR: Checksum verification failed for $file" >&2
    echo "Expected: $expected_sha256" >&2
    echo "Actual:   $actual_sha256" >&2
    return 1
  fi
  
  echo "Checksum verified for $file"
  return 0
}

# Execute script safely
safe_execute() {
  local script="$1"
  shift
  
  # Check if file exists
  if [[ ! -f "$script" ]]; then
    echo "ERROR: Script file not found: $script" >&2
    return 1
  fi
  
  # Check if file is readable
  if [[ ! -r "$script" ]]; then
    echo "ERROR: Script is not readable: $script" >&2
    return 1
  fi
  
  # Execute with parameters
  bash "$script" "$@"
  return $?
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

log_section() {
    echo ""
    echo -e "${MAGENTA}════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}🌲 $*${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════════${NC}"
}

log_step() {
    echo -e "${BLUE}→${NC} $*"
}

log_step() {
    echo -e "${BLUE}→${NC} $*"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

require_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_warn "This step requires sudo. Please authenticate:"
        sudo -v
    fi
}

# ============================================================================
# PHASE 1: SYSTEM VERIFICATION & PREPARATION
# ============================================================================

phase_verify_system() {
    log_section "System Verification & Preparation"
    
    log_step "Detecting SteamOS version..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" = "steamos" ]; then
            log_success "SteamOS detected: $PRETTY_NAME"
            STEAMOS_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            if ! echo "$STEAMOS_VERSION" | grep -qE "^[0-9]+$"; then
                log_error "Could not parse SteamOS version: $VERSION_ID"
                exit 1
            fi
            if [ "$STEAMOS_VERSION" -ge 3 ]; then
                log_success "SteamOS 3.x confirmed - Arch-based environment"
            else
                log_error "This script requires SteamOS 3.x. Your version: $VERSION_ID"
                exit 1
            fi
        else
            log_error "Not running SteamOS. Detected: $ID"
            exit 1
        fi
    else
        log_error "Cannot determine system - /etc/os-release not found"
        exit 1
    fi
    
    log_step "Verifying package manager..."
    if check_command pacman; then
        log_success "pacman package manager available"
    else
        log_error "pacman not found - SteamOS environment may be corrupted"
        exit 1
    fi
    
    log_step "Checking sudo access..."
    require_sudo
    log_success "sudo access confirmed"
    
    log_step "Detecting SteamOS filesystem mode..."
    if [ -e /proc/cmdline ] && grep -q "steamos_cmdline" /proc/cmdline 2>/dev/null; then
        log_success "SteamOS kernel detected"
    fi
}

# ============================================================================
# PHASE 2: SYSTEM UPDATE & BASIC TOOLS
# ============================================================================

phase_system_update() {
    log_section "System Update & Basic Tools"
    
    log_step "Syncing pacman package database..."
    if sudo pacman -Syu --noconfirm; then
        log_success "System packages synchronized"
    else
        log_warn "pacman sync had issues - retrying with force refresh"
        if sudo pacman -Syy --noconfirm; then
            log_success "System packages synchronized (force refresh)"
        else
            log_error "pacman sync failed - system may not be fully updated"
        fi
    fi
    
    log_step "Installing essential tools..."
    local ESSENTIAL_PKGS=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "zip"
        "htop"
        "tmux"
        "nano"
        "openssh"
        "openssh-askpass"
    )
    
    for pkg in "${ESSENTIAL_PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            log_success "$pkg already installed"
        else
            if sudo pacman -S "$pkg" --noconfirm; then
                log_success "$pkg installed"
            else
                log_error "$pkg installation failed"
            fi
        fi
    done
    
    log_step "Installing system utilities..."
    local UTIL_PKGS=(
        "man-db"
        "fzf"
        "bat"
        "ripgrep"
        "fd"
        "jq"
        "yamllint"
    )
    
    for pkg in "${UTIL_PKGS[@]}"; do
        sudo pacman -S "$pkg" --noconfirm 2>/dev/null || log_warn "Optional utility $pkg not available"
    done
    
    log_success "Essential tools installed"
}

# ============================================================================
# PHASE 3: DEVELOPMENT TOOLCHAINS
# ============================================================================

phase_dev_toolchains() {
    log_section "Development Toolchains"
    
    log_step "Installing Python ecosystem..."
    local PYTHON_PKGS=("python" "python-pip" "python-virtualenv" "python-black" "python-mypy")
    for pkg in "${PYTHON_PKGS[@]}"; do
        sudo pacman -S "$pkg" --noconfirm || log_warn "Could not install $pkg"
    done
    python --version
    pip --version
    log_success "Python 3 ready"
    
    log_step "Installing Node.js & npm..."
    sudo pacman -S nodejs npm --noconfirm || log_warn "Node.js installation had issues"
    node --version
    npm --version
    log_success "Node.js & npm ready"
    
    log_step "Installing Java Development Kit..."
    sudo pacman -S jdk-openjdk --noconfirm || log_warn "OpenJDK installation had issues"
    java -version 2>&1 | head -1
    log_success "Java ready"
    
    log_step "Installing Rust & Cargo..."
    sudo pacman -S rust cargo --noconfirm || log_warn "Rust installation had issues"
    rustc --version
    cargo --version
    log_success "Rust & Cargo ready"
    
    log_step "Installing Go..."
    sudo pacman -S go --noconfirm || log_warn "Go installation had issues"
    go version 2>/dev/null || log_warn "Go version check failed"
    log_success "Go ready"
    
    log_step "Installing .NET SDK..."
    sudo pacman -S dotnet-sdk --noconfirm || log_warn ".NET SDK not available in repos (download from microsoft.com or use: flatpak install flathub org.freedesktop.Sdk.Extension.dotnet)"
    
    log_step "Installing build tools..."
    local BUILD_PKGS=("make" "cmake" "gcc" "clang" "gdb" "valgrind")
    for pkg in "${BUILD_PKGS[@]}"; do
        sudo pacman -S "$pkg" --noconfirm || log_warn "Could not install $pkg"
    done
    log_success "Build toolchain ready"
}

# ============================================================================
# PHASE 4: VERSION CONTROL & GIT CONFIGURATION
# ============================================================================

phase_git_setup() {
    log_section "Git & Version Control Setup"
    
    git --version
    log_success "Git verified"
    
    log_step "Configuring git identity..."
    if ! git config --global user.name &>/dev/null; then
        log_warn "Git user.name not configured"
        if read -r -t 30 -p "Enter your Git name: " GIT_NAME; then
            git config --global user.name "$GIT_NAME"
        else
            log_warn "Git name configuration skipped (timeout)"
        fi
    else
        log_success "Git user.name already configured: $(git config --global user.name)"
    fi
    
    if ! git config --global user.email &>/dev/null; then
        log_warn "Git user.email not configured"
        if read -r -t 30 -p "Enter your Git email: " GIT_EMAIL; then
            git config --global user.email "$GIT_EMAIL"
        else
            log_warn "Git email configuration skipped (timeout)"
        fi
    else
        log_success "Git user.email already configured: $(git config --global user.email)"
    fi
    
    log_step "Setting up SSH..."
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        log_warn "SSH key not found - generating ed25519 key..."
        log_info "You will be prompted to set a passphrase (recommended for security)"
        if ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(git config --global user.email)"; then
            if [ -f ~/.ssh/id_ed25519.pub ]; then
                log_success "SSH key generated at ~/.ssh/id_ed25519"
                log_info "Add this public key to GitHub:"
                cat ~/.ssh/id_ed25519.pub
            fi
        else
            log_warn "SSH key generation failed (key may already exist or passphrase was declined)"
        fi
    else
        log_success "SSH key already exists"
    fi
    
    log_step "Installing GitHub CLI..."
    sudo pacman -S github-cli --noconfirm || log_warn "GitHub CLI not available"
    
    if check_command gh; then
        log_success "GitHub CLI ready"
    fi
}

# ============================================================================
# PHASE 5: FLATPAK SETUP & GUI APPLICATIONS
# ============================================================================

phase_flatpak_setup() {
    log_section "Flatpak Setup & GUI Applications"
    
    log_step "Installing Flatpak..."
    if check_command flatpak; then
        log_success "Flatpak already installed"
    else
        sudo pacman -S flatpak --noconfirm || {
            log_error "Flatpak installation failed"
            return 1
        }
        log_success "Flatpak installed"
    fi
    
    log_step "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    log_success "Flathub configured"
    
    log_step "Installing development applications via Flatpak..."
    
    local FLATPAK_APPS=(
        "io.github.GodotEngine.Godot:Godot Game Engine"
        "com.unity.UnityHub:Unity Hub"
        "org.gimp.GIMP:GIMP Image Editor"
        "com.jetbrains.Rider:JetBrains Rider IDE"
        "com.jetbrains.IntelliJ-IDEA-Community:IntelliJ IDEA (Community)"
        "com.visualstudio.code:Visual Studio Code"
        "org.gnome.gedit:GNOME Text Editor"
        "com.github.mjakeman.text-pieces:Text Pieces"
        "com.lutris.Lutris:Lutris Gaming Platform"
    )
    
    for app_entry in "${FLATPAK_APPS[@]}"; do
        app_id="${app_entry%%:*}"
        app_name="${app_entry##*:}"
        log_step "Checking $app_name ($app_id)..."
        if flatpak list --app | grep -qE "^[[:space:]]*${app_id}[[:space:]]"; then
            log_success "$app_name already installed"
        else
            log_info "Installing $app_name..."
            flatpak install -y flathub "$app_id" 2>/dev/null || log_warn "Could not install $app_name (may require manual auth or be unavailable)"
        fi
    done
    
    log_success "Flatpak applications configured"
}

# ============================================================================
# PHASE 6: CONTAINER & VIRTUALIZATION TOOLS
# ============================================================================

phase_containers() {
    log_section "Container & Virtualization Tools"
    
    log_step "Installing Docker..."
    if sudo pacman -S docker --noconfirm 2>/dev/null; then
        log_success "Docker installed"
        
        log_step "Enabling Docker service..."
        if sudo systemctl enable docker; then
            log_success "Docker service enabled"
        else
            log_warn "Could not enable Docker service - you may need to enable it manually"
        fi
        
        if sudo systemctl start docker 2>/dev/null; then
            log_success "Docker service started"
        else
            log_warn "Could not start Docker service (may need reboot after bootstrap completes)"
        fi
        
        log_step "Adding user to docker group..."
        if sudo usermod -aG docker "$USER"; then
            log_success "User added to docker group"
            log_warn "⚠️  IMPORTANT: You must log out and back in (or run 'newgrp docker') for group membership to take effect"
        else
            log_warn "Could not add user to docker group - you may need to do this manually: sudo usermod -aG docker \$USER"
        fi
    else
        log_warn "Docker not available in repos"
    fi
    
    log_step "Installing Podman..."
    if sudo pacman -S podman podman-compose --noconfirm 2>/dev/null; then
        log_success "Podman installed"
    else
        log_warn "Podman installation skipped (not available in repos)"
    fi
}

# ============================================================================
# PHASE 7: SHELL ENVIRONMENT & PATH SETUP
# ============================================================================

phase_shell_setup() {
    log_section "Shell Environment Configuration"
    
    log_step "Detecting shell..."
    local CURRENT_SHELL
    CURRENT_SHELL=$(basename "$SHELL")
    log_info "Current shell: $CURRENT_SHELL"
    
    local SHELL_CONFIG=""
    if [ "$CURRENT_SHELL" = "bash" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ "$CURRENT_SHELL" = "zsh" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ "$CURRENT_SHELL" = "fish" ]; then
        SHELL_CONFIG="$HOME/.config/fish/config.fish"
    elif [ "$CURRENT_SHELL" = "ksh" ]; then
        SHELL_CONFIG="$HOME/.kshrc"
    fi
    
    if [ -z "$SHELL_CONFIG" ]; then
        log_warn "Shell configuration file not detected - skipping"
        return
    fi
    
    log_step "Updating $SHELL_CONFIG with development paths..."
    
    # Create backup
    if [ -f "$SHELL_CONFIG" ]; then
        cp "$SHELL_CONFIG" "${SHELL_CONFIG}.bak.$(date +%s)"
        log_info "Backup created"
    fi
    
    # Append development environment variables if not already present
    if ! grep -q "# Development environment bootstrap" "$SHELL_CONFIG"; then
        cat >> "$SHELL_CONFIG" << 'EOF'

# ============================================================================
# Development environment bootstrap
# ============================================================================

# Python environment
export PYTHONUNBUFFERED=1
export PIP_REQUIRE_VIRTUALENV=false

# Node.js environment
export NODE_ENV=development

# Rust environment
if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go environment
if [ -d "/usr/lib/go" ]; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Development aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias python=python3
alias pip=pip3

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'

# Development helpers
alias py='python3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Enhanced prompt (if not already set)
if [ -z "${PS1:-}" ]; then
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

EOF
        log_success "Development environment variables added to $SHELL_CONFIG"
    else
        log_info "$SHELL_CONFIG already contains development configuration"
    fi
}

# ============================================================================
# PHASE 8: VALIDATION & SMOKE TESTS
# ============================================================================

phase_validation() {
    log_section "Validation & Smoke Tests"
    
    local TESTS_PASSED=0
    local TESTS_FAILED=0
    
    local COMMANDS=(
        "git:git --version"
        "python3:python3 --version"
        "pip:pip --version"
        "node:node --version"
        "npm:npm --version"
        "java:java -version"
        "rustc:rustc --version"
        "cargo:cargo --version"
        "go:go version"
        "make:make --version"
        "curl:curl --version"
        "wget:wget --version"
        "flatpak:flatpak --version"
    )
    
    for test_entry in "${COMMANDS[@]}"; do
        cmd_name="${test_entry%%:*}"
        cmd_check="${test_entry##*:}"
        
        if check_command "$cmd_name"; then
            output=$($cmd_check 2>&1 | head -1)
            echo -e "${GREEN}✓${NC} $cmd_name: $output"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗${NC} $cmd_name: NOT FOUND"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
    
    log_section "Smoke Test Results"
    echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC} | Failed: ${RED}${TESTS_FAILED}${NC}"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        log_success "All core tools operational!"
    else
        log_warn "$TESTS_FAILED tools missing or failed"
    fi
}

# ============================================================================
# PHASE 9: POST-BOOTSTRAP INSTRUCTIONS
# ============================================================================

phase_completion() {
    log_section "Bootstrap Complete! 🌲"
    
    cat << 'EOF'

The development sanctuary is now prepared. Here's your next journey:

📝 IMMEDIATE ACTIONS:
  1. Source your shell config to load new environment:
     source ~/.bashrc    # or ~/.zshrc
  
  2. Verify Docker group membership (if installed):
     newgrp docker       # or log out and back in
  
  3. Check SSH key was added to GitHub:
     cat ~/.ssh/id_ed25519.pub
  
  4. Clone your development projects:
     cd ~/Development
     git clone git@github.com:yourrepo/project.git

⚙️ OPTIONAL INSTALLATIONS:
  If you need additional tools, use:
    sudo pacman -S <package>        # For system packages
    flatpak install flathub <app>   # For GUI applications
    pip install <package>            # For Python packages
    npm install -g <package>         # For Node.js packages
    cargo install <package>          # For Rust tools
    go install github.com/user/repo@latest  # For Go tools

📚 IMPORTANT NOTES:
  • SteamOS uses a read-only root filesystem. Major changes may require:
    sudo steamos-readonly disable   # Before system changes
    sudo steamos-readonly enable    # After changes
  
  • Flatpak apps run in sandbox. For development, command-line tools via
    pacman or language package managers are often better.
  
  • Docker may need a reboot or newgrp to work without sudo
  
  • Some applications (Epic Games, etc.) may require additional
    Proton/Wine configuration via Lutris

🚀 NEXT STEPS:
  • Configure your IDE (VS Code, Rider, IntelliJ) with projects
  • Set up any language-specific environments (venv, nvm, etc.)
  • Install game engines (Godot, Unity) and configure projects
  • Test your development workflow end-to-end

May your code be ever elegant and your builds swift! 🌲

EOF

    log_success "Bootstrap ritual complete - the forest awaits your creativity"
}

# ============================================================================
# MAIN EXECUTION FLOW
# ============================================================================

main() {
    log_section "SteamOS Development Bootstrap - Beginning Ritual"
    
    echo "This script will configure your SteamOS system for development."
    echo "It will install: dev tools, programming languages, IDEs, games engines, and more."
    echo ""
    read -p "Continue? (y/n) " -n 1 -r REPLY
    echo
    if ! echo "$REPLY" | grep -qE "^[Yy]$"; then
        log_warn "Bootstrap cancelled"
        exit 0
    fi
    
    # Execute phases
    phase_verify_system
    phase_system_update
    phase_dev_toolchains
    phase_git_setup
    phase_flatpak_setup
    phase_containers
    phase_shell_setup
    phase_validation
    phase_completion
}

# Run main
main "$@"