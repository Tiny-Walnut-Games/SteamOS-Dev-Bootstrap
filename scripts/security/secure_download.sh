#!/bin/bash
# Security helper functions for bootstrap scripts
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
