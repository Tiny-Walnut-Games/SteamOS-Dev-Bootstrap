#!/bin/bash
# Security audit script for SteamOS-Dev-Bootstrap
# Checks for common security issues in the repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

# Change to repository root
cd "$(dirname "$0")/../.."

log_info "Running security audit on repository..."

# Check for shellcheck
if ! command -v shellcheck &> /dev/null; then
  log_warn "ShellCheck not found. Some checks will be skipped."
  SHELLCHECK_AVAILABLE=false
else
  SHELLCHECK_AVAILABLE=true
fi

# 1. Check for hardcoded credentials
log_info "Checking for hardcoded credentials..."
CREDENTIAL_PATTERNS=$(grep -r -E "(password|token|secret|key|credential).*=.*['\"].*['\"]" --include="*.sh" . | 
  grep -v "scripts/security/security_audit.sh" | 
  grep -v "test.sh" | 
  grep -v "# " || true)

if [ -n "$CREDENTIAL_PATTERNS" ]; then
  log_error "Potential credential patterns found:"
  echo "$CREDENTIAL_PATTERNS"
else
  log_success "No hardcoded credentials found"
fi

# 2. Check for insecure certificate validation
log_info "Checking for insecure certificate validation..."
INSECURE_CERT=$(grep -r "curl.*-k\|wget.*--no-check-certificate" --include="*.sh" . | 
  grep -v "scripts/security/security_audit.sh" | 
  grep -v "test.sh" | 
  grep -v "# " || true)

if [ -n "$INSECURE_CERT" ]; then
  log_error "Insecure certificate validation found:"
  echo "$INSECURE_CERT"
else
  log_success "No insecure certificate validation found"
fi

# 3. Check for unsafe pipe patterns
log_info "Checking for unsafe pipe patterns..."
UNSAFE_PATTERNS=$(grep -r "curl.*|.*sh\|wget.*|.*sh" --include="*.sh" . | 
  grep -v "test/ubuntu-adaptation.sh" | 
  grep -v "scripts/security/security_audit.sh" | 
  grep -v "scripts/secure_bootstrap.sh" | 
  grep -v "test.sh" | 
  grep -v "# " || true)

if [ -n "$UNSAFE_PATTERNS" ]; then
  log_warn "Unsafe pipe-to-shell patterns found outside of test files:"
  echo "$UNSAFE_PATTERNS"
else
  log_success "No unsafe pipe patterns found outside of test files"
fi

# 4. Run ShellCheck on main script
if [ "$SHELLCHECK_AVAILABLE" = true ]; then
  log_info "Running ShellCheck on bootstrap-steamos.sh..."
  if shellcheck bootstrap-steamos.sh; then
    log_success "ShellCheck passed for bootstrap-steamos.sh"
  else
    log_error "ShellCheck found issues in bootstrap-steamos.sh"
  fi
fi

# 5. Check for world-writable files
log_info "Checking for world-writable files..."
WORLD_WRITABLE=$(find . -type f -perm -002 -not -path "*/\.git/*" || true)

if [ -n "$WORLD_WRITABLE" ]; then
  log_warn "World-writable files found:"
  echo "$WORLD_WRITABLE"
else
  log_success "No world-writable files found"
fi

# 6. Check for executable bit on non-script files
log_info "Checking for executable bit on non-script files..."
EXECUTABLE_NON_SCRIPTS=$(find . -type f -executable -not -path "*/\.git/*" -not -path "*/.zencoder/*" | grep -v "\.sh$" || true)

if [ -n "$EXECUTABLE_NON_SCRIPTS" ]; then
  log_warn "Executable bit set on non-script files:"
  echo "$EXECUTABLE_NON_SCRIPTS"
else
  log_success "No unexpected executable files found"
fi

# 7. Check for Docker security
log_info "Checking Docker security..."
if grep -q "FROM.*latest" Dockerfile; then
  log_warn "Dockerfile uses 'latest' tag - consider using specific version"
else
  log_success "Dockerfile uses specific version tag"
fi

if grep -q "USER root" Dockerfile; then
  log_warn "Dockerfile runs as root - consider using non-root user"
else
  log_success "Dockerfile doesn't explicitly run as root"
fi

# 8. Check GitHub Actions workflow security
log_info "Checking GitHub Actions workflow security..."
if grep -q "uses: actions/checkout@v3" .github/workflows/ci-cd.yml; then
  log_success "GitHub Actions uses pinned action versions"
else
  log_warn "GitHub Actions might not use pinned action versions"
fi

# Summary
echo ""
echo "Security Audit Summary:"
echo "======================="
echo "✅ Credential check"
echo "✅ Certificate validation check"
echo "✅ Pipe pattern check"
if [ "$SHELLCHECK_AVAILABLE" = true ]; then
  echo "✅ ShellCheck analysis"
else
  echo "⚠️ ShellCheck analysis (skipped)"
fi
echo "✅ File permission check"
echo "✅ Docker security check"
echo "✅ GitHub Actions security check"

echo ""
log_info "Security audit completed"
