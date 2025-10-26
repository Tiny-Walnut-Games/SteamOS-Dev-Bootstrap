#!/bin/bash
# Update version across all project files

set -e

# Check if version is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.0.1"
  exit 1
fi

VERSION=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Update VERSION file
echo "$VERSION" > "$PROJECT_ROOT/VERSION"
echo "Updated VERSION file to $VERSION"

# Update bootstrap-steamos.sh version
if grep -q "^VERSION=" "$PROJECT_ROOT/bootstrap-steamos.sh"; then
  # Version variable already exists, update it
  sed -i "s/^VERSION=.*/VERSION=\"$VERSION\"/" "$PROJECT_ROOT/bootstrap-steamos.sh"
else
  # Version variable doesn't exist, add it after the shebang line
  sed -i "1a\VERSION=\"$VERSION\"" "$PROJECT_ROOT/bootstrap-steamos.sh"
fi
echo "Updated bootstrap-steamos.sh version to $VERSION"

echo "Version updated successfully to $VERSION"
