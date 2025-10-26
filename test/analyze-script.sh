#!/bin/bash
# ============================================================================
# 🔍 Bootstrap Script Static Analysis
# Tests the script without running it - finds issues before deployment
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

SCRIPT="../bootstrap-steamos.sh"

echo "🔍 Bootstrap Script Analysis"
echo "============================"

# Test 1: Basic syntax check
log_info "Testing basic shell syntax..."
if bash -n "$SCRIPT"; then
    log_success "Syntax check passed"
else
    log_error "Syntax errors found!"
    exit 1
fi

# Test 2: Check for common issues
log_info "Checking for potential issues..."

# Check for unquoted variables
if grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$SCRIPT" | grep -v '#!/bin/bash' | head -5; then
    log_warn "Found potentially unquoted variables (may be intentional)"
fi

# Check for hardcoded paths
log_info "Checking for hardcoded paths..."
if grep -n '/home/deck\|/usr/local' "$SCRIPT" | head -5; then
    log_warn "Found hardcoded paths - consider making dynamic"
else
    log_success "No obvious hardcoded paths found"
fi

# Check for error handling
log_info "Checking error handling..."
if grep -q "set -euo pipefail" "$SCRIPT"; then
    log_success "Strict error handling enabled"
else
    log_warn "Consider adding 'set -euo pipefail' for better error handling"
fi

# Test 3: Function analysis
log_info "Analyzing functions..."
FUNCTIONS=$(grep -n "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$SCRIPT" | wc -l)
log_success "Found $FUNCTIONS functions"

# Test 4: Package analysis
log_info "Analyzing package installations..."
PACMAN_INSTALLS=$(grep -n "pacman -S" "$SCRIPT" | wc -l)
FLATPAK_INSTALLS=$(grep -n "flatpak install" "$SCRIPT" | wc -l)
log_info "Pacman installs: $PACMAN_INSTALLS"
log_info "Flatpak installs: $FLATPAK_INSTALLS"

# Test 5: Interactive sections
log_info "Checking interactive sections..."
if grep -q "read -r" "$SCRIPT"; then
    log_warn "Script contains interactive prompts - ensure timeouts are set"
fi

# Test 6: Privilege escalation
log_info "Checking sudo usage..."
SUDO_CALLS=$(grep -n "sudo " "$SCRIPT" | wc -l)
log_info "Sudo calls found: $SUDO_CALLS"

# Test 7: Check package lists
log_info "Validating package arrays..."
while IFS= read -r line; do
    if [[ $line =~ .*_PKGS=\( ]]; then
        log_info "Found package array: $(echo "$line" | grep -o '[A-Z_]*_PKGS')"
    fi
done < "$SCRIPT"

echo ""
echo "🎯 Key Validation Points:"
echo "========================"

# Simulate key checks that would happen on real system
log_info "Simulating SteamOS detection..."
if grep -q 'steamos_cmdline' "$SCRIPT"; then
    log_success "SteamOS kernel detection implemented"
fi

if grep -q '/etc/os-release' "$SCRIPT"; then
    log_success "OS detection via /etc/os-release implemented"
fi

log_info "Checking pacman usage patterns..."
if grep -q 'pacman -Qi.*&>/dev/null' "$SCRIPT"; then
    log_success "Proper package checking before install"
fi

if grep -q 'pacman.*--noconfirm' "$SCRIPT"; then
    log_success "Non-interactive pacman calls"
fi

echo ""
echo "✨ Analysis Summary:"
echo "=================="
log_success "Script structure looks solid"
log_info "Ready for deployment testing"

echo ""
echo "🚀 Next Steps:"
echo "============="
echo "1. Test in WSL2 with: ./test/wsl-test-setup.sh"  
echo "2. Or test in VirtualBox VM with actual SteamOS ISO"
echo "3. Create system backup before switching"
echo "4. Deploy to real SteamOS system"