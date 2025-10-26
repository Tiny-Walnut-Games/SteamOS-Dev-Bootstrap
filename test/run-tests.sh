#!/bin/bash
# ============================================================================
# 🧪 Bootstrap Script Test Runner
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

# Test 1: Arch Linux Simulation (closest to SteamOS)
test_arch_simulation() {
    echo "🐧 Testing with Arch Linux (SteamOS simulation)"
    
    if command -v docker &> /dev/null; then
        log_info "Building Arch test container..."
        docker build -f test/docker/Dockerfile.arch -t steamos-test .
        
        log_info "Running bootstrap test in Arch container..."
        docker run --rm -it steamos-test ./bootstrap-steamos.sh
        
        log_success "Arch simulation test completed"
    else
        log_warn "Docker not available - skipping Arch simulation"
    fi
}

# Test 2: Ubuntu Adaptation Test
test_ubuntu_adaptation() {
    echo "🐧 Testing with Ubuntu (functionality verification)"
    
    if command -v docker &> /dev/null; then
        log_info "Building Ubuntu test container..."
        docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-test .
        
        log_info "Running adaptation test in Ubuntu container..."
        docker run --rm -it ubuntu-test ./test/ubuntu-adaptation.sh
        
        log_success "Ubuntu adaptation test completed"
    else
        log_warn "Docker not available - skipping Ubuntu test"
    fi
}

# Test 3: Static Analysis
test_static_analysis() {
    echo "🔍 Running static analysis..."
    
    log_info "Checking script syntax..."
    bash -n bootstrap-steamos.sh && log_success "Syntax check passed"
    
    log_info "Checking for common issues..."
    if command -v shellcheck &> /dev/null; then
        shellcheck bootstrap-steamos.sh && log_success "ShellCheck passed"
    else
        log_warn "ShellCheck not available - install with: sudo apt install shellcheck"
    fi
    
    log_info "Checking for hardcoded paths..."
    if grep -n "/home/deck" bootstrap-steamos.sh; then
        log_warn "Found hardcoded /home/deck paths - consider making them dynamic"
    else
        log_success "No hardcoded paths found"
    fi
}

# Test 4: Interactive Mode Simulation
test_interactive_simulation() {
    echo "🤖 Testing interactive prompts..."
    
    log_info "Testing git configuration prompts..."
    # You could add expect scripts here for full automation
    log_warn "Interactive tests require manual verification"
}

# Main test runner
main() {
    echo "🧪 Bootstrap Script Test Suite"
    echo "=============================="
    
    cd "$(dirname "$0")/.."
    
    test_static_analysis
    echo ""
    
    if [ "${1:-}" = "--docker" ]; then
        test_arch_simulation
        echo ""
        test_ubuntu_adaptation
    else
        log_info "Run with --docker flag to execute container tests"
        log_info "Example: ./test/run-tests.sh --docker"
    fi
    
    echo ""
    echo "🎉 Test suite completed!"
    echo ""
    echo "Next steps:"
    echo "1. Fix any issues found above"
    echo "2. Test in a VM with actual SteamOS ISO"
    echo "3. Create a USB backup before switching"
}

main "$@"