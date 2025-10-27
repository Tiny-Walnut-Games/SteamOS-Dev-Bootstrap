#!/bin/bash
# Script to update bootstrap-steamos.sh with secure download functions
# This script adds security helper functions to the bootstrap script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

BOOTSTRAP_SCRIPT="bootstrap-steamos.sh"
SECURITY_HELPERS="scripts/security/secure_download.sh"
TEMP_SCRIPT="bootstrap-steamos.sh.tmp"

# Check if files exist
if [[ ! -f "$BOOTSTRAP_SCRIPT" ]]; then
  log_error "Bootstrap script not found: $BOOTSTRAP_SCRIPT"
  exit 1
fi

if [[ ! -f "$SECURITY_HELPERS" ]]; then
  log_error "Security helpers not found: $SECURITY_HELPERS"
  exit 1
fi

log_info "Updating bootstrap script with security functions..."

# Extract security functions
SECURITY_FUNCTIONS=$(cat "$SECURITY_HELPERS")

# Create a temporary file with security functions added
{
  # Add header comment
  echo "#!/bin/bash"
  echo "# ============================================================================"
  echo "# 🌲 SteamOS Development Environment Bootstrap"
  echo "# For SteamOS 3.x (Holo) - First Login Ritual"
  echo "# ============================================================================"
  echo "# This script transforms a fresh SteamOS installation into a full development"
  echo "# sanctuary, installing all essential tools, dev toolchains, and applications."
  echo "#"
  echo "# Run this on first login:"
  echo "#   Option 1 (Recommended): Download and verify before running"
  echo "#     curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh -o bootstrap-steamos.sh"
  echo "#     less bootstrap-steamos.sh  # Review the script"
  echo "#     bash bootstrap-steamos.sh"
  echo "#"
  echo "#   Option 2: Direct execution (only if you trust the source)"
  echo "#     curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh | bash"
  echo "# ============================================================================"
  echo ""
  echo "set -euo pipefail"
  echo ""
  
  # Extract version from original script
  VERSION=$(grep "^VERSION=" "$BOOTSTRAP_SCRIPT" | cut -d'"' -f2 || echo "1.0.0")
  echo "VERSION=\"$VERSION\""
  echo ""
  
  # Add colors section
  echo "# Colors for output (respecting terminal support)"
  echo "RED='\033[0;31m'"
  echo "GREEN='\033[0;32m'"
  echo "YELLOW='\033[1;33m'"
  echo "BLUE='\033[0;34m'"
  echo "MAGENTA='\033[0;35m'"
  echo "NC='\033[0m' # No Color"
  echo ""
  
  # Add security functions
  echo "# ============================================================================"
  echo "# SECURITY FUNCTIONS"
  echo "# ============================================================================"
  echo ""
  # Remove shebang and comments from security functions
  echo "$SECURITY_FUNCTIONS" | grep -v "^#!/bin/bash" | grep -v "^# Security helper"
  echo ""
  
  # Add utility functions
  echo "# ============================================================================"
  echo "# UTILITY FUNCTIONS"
  echo "# ============================================================================"
  echo ""
  echo "log_info() {"
  echo "    echo -e \"\${BLUE}ℹ\${NC} \$*\""
  echo "}"
  echo ""
  echo "log_success() {"
  echo "    echo -e \"\${GREEN}✓\${NC} \$*\""
  echo "}"
  echo ""
  echo "log_warn() {"
  echo "    echo -e \"\${YELLOW}⚠\${NC} \$*\""
  echo "}"
  echo ""
  echo "log_error() {"
  echo "    echo -e \"\${RED}✗\${NC} \$*\""
  echo "}"
  echo ""
  echo "log_section() {"
  echo "    echo \"\""
  echo "    echo -e \"\${MAGENTA}════════════════════════════════════════════════════════════\${NC}\""
  echo "    echo -e \"\${MAGENTA}🌲 \$*\${NC}\""
  echo "    echo -e \"\${MAGENTA}════════════════════════════════════════════════════════════\${NC}\""
  echo "}"
  echo ""
  echo "log_step() {"
  echo "    echo -e \"\${BLUE}→\${NC} \$*\""
  echo "}"
  echo ""
  
  # Add the rest of the script, replacing unsafe patterns
  tail -n +50 "$BOOTSTRAP_SCRIPT" | 
    # Replace curl | bash patterns with secure alternatives
    sed 's/curl -fsSL \(https:\/\/[^ ]*\) | bash/secure_download "\1" "\/tmp\/script.sh" \&\& safe_execute "\/tmp\/script.sh"/g' |
    # Replace wget | bash patterns
    sed 's/wget -qO- \(https:\/\/[^ ]*\) | bash/secure_download "\1" "\/tmp\/script.sh" \&\& safe_execute "\/tmp\/script.sh"/g'
  
} > "$TEMP_SCRIPT"

# Make the new script executable
chmod +x "$TEMP_SCRIPT"

log_success "Bootstrap script updated with security functions"
log_info "New script saved as: $TEMP_SCRIPT"
log_info "Review the changes and then replace the original script:"
log_info "  mv $TEMP_SCRIPT $BOOTSTRAP_SCRIPT"

exit 0
