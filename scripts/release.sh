#!/bin/bash
# Create a new release

set -e

# Check if version is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.0.1"
  exit 1
fi

VERSION=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update version
"$SCRIPT_DIR/update_version.sh" "$VERSION"

# Commit changes
git add ../VERSION ../bootstrap-steamos.sh
git commit -m "Release v$VERSION"

# Create tag
git tag -a "v$VERSION" -m "Release v$VERSION"

echo "Release v$VERSION prepared."
echo "Run 'git push && git push --tags' to publish the release."
