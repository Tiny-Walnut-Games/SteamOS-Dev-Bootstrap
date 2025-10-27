#!/bin/bash
# Comprehensive test script for local development

set -e

# Default test mode
TEST_MODE="full"
AUTO_YES=false
SKIP_BUILD=false
SECURITY_SCAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verify-only)
      TEST_MODE="verify"
      shift
      ;;
    --quick)
      TEST_MODE="quick"
      shift
      ;;
    --full)
      TEST_MODE="full"
      shift
      ;;
    --security-scan)
      SECURITY_SCAN=true
      shift
      ;;
    --auto-yes)
      AUTO_YES=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --verify-only   Only run system verification phase"
      echo "  --quick         Run minimal test (verification + basic packages)"
      echo "  --full          Run full test (default)"
      echo "  --security-scan Run security scan on scripts"
      echo "  --auto-yes      Automatically answer yes to all prompts"
      echo "  --skip-build    Skip rebuilding the Docker image"
      echo "  --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Run security scan if requested
if [ "$SECURITY_SCAN" = true ]; then
  echo "Running security scan..."
  
  # Check for shellcheck
  if ! command -v shellcheck &> /dev/null; then
    echo "Error: shellcheck not found. Please install it first."
    exit 1
  fi
  
  # Run shellcheck on bootstrap script
  echo "Checking bootstrap-steamos.sh..."
  shellcheck -S warning bootstrap-steamos.sh
  
  # Check for unsafe patterns
  echo "Checking for unsafe patterns..."
  
  # Check for pipe-to-shell patterns
  if grep -r "curl.*|.*sh\|wget.*|.*sh" --include="*.sh" . | \
     grep -v "test/ubuntu-adaptation.sh" | \
     grep -v "scripts/security/security_audit.sh" | \
     grep -v "scripts/secure_bootstrap.sh" | \
     grep -v "bootstrap-steamos.sh" | \
     grep -v "# "; then
    echo "Warning: Unsafe pipe-to-shell patterns found outside of test files"
  fi
  
  # Check for insecure certificate validation
  if grep -r "curl.*-k\|wget.*--no-check-certificate" --include="*.sh" . | \
     grep -v "scripts/security/security_audit.sh" | \
     grep -v "test.sh" | \
     grep -v "# "; then
    echo "Error: Insecure certificate validation found"
    exit 1
  fi
  
  # Check for hardcoded credentials
  if grep -r -E "(password|token|secret|key|credential).*=.*['\"].*['\"]" --include="*.sh" . | \
     grep -v "scripts/security/security_audit.sh" | \
     grep -v "test.sh" | \
     grep -v "# "; then
    echo "Warning: Potential credential patterns found (manual review required)"
  fi
  
  echo "Security scan completed"
  exit 0
fi

# Build Docker image if not skipped
if [ "$SKIP_BUILD" = false ]; then
  echo "Building test container..."
  docker-compose build
fi

# Prepare test command based on mode
TEST_CMD="./bootstrap-steamos.sh"

case $TEST_MODE in
  verify)
    TEST_CMD="$TEST_CMD --verify-only"
    ;;
  quick)
    TEST_CMD="$TEST_CMD --quick"
    ;;
  full)
    # Default, no additional args needed
    ;;
esac

# Add auto-yes if specified
if [ "$AUTO_YES" = true ]; then
  TEST_CMD="$TEST_CMD --auto-yes"
fi

DOCKER_CMD="$TEST_CMD"

echo "Running bootstrap script in test container (mode: $TEST_MODE)..."
docker-compose run --rm steamos-test bash -c "$DOCKER_CMD"

echo "Test completed successfully!"
