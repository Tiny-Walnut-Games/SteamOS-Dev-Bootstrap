# Release Process

This document outlines the process for creating and publishing new releases of the SteamOS Development Environment Bootstrap script.

## Versioning

We follow [Semantic Versioning](https://semver.org/) (SemVer) for this project:

- **MAJOR** version for incompatible changes (e.g., changes that might break existing setups)
- **MINOR** version for new features in a backward-compatible manner
- **PATCH** version for backward-compatible bug fixes

## Release Checklist

Before creating a new release, ensure:

1. All tests pass in the CI/CD pipeline
2. The script has been tested on a real SteamOS device (if possible)
3. All changes are documented in commit messages
4. The VERSION file and script version are in sync

## Creating a Release

### Automated Release Process

1. Update the version using the version script:
   ```bash
   ./scripts/update_version.sh 1.0.1
   ```

2. Use the release script to commit, tag, and prepare the release:
   ```bash
   ./scripts/release.sh 1.0.1
   ```

3. Push the changes and tag:
   ```bash
   git push && git push --tags
   ```

The CI/CD pipeline will automatically:
- Validate the script
- Run security scans
- Test the script in a Docker environment
- Create a GitHub release with the bootstrap script attached
- Generate release notes from commit messages

### Manual Release Process

If you need to create a release manually:

1. Update the version in all relevant files:
   - `VERSION` file
   - `bootstrap-steamos.sh` (VERSION variable)

2. Commit the changes:
   ```bash
   git add VERSION bootstrap-steamos.sh
   git commit -m "Release v1.0.1"
   ```

3. Create a tag:
   ```bash
   git tag -a "v1.0.1" -m "Release v1.0.1"
   ```

4. Push the changes and tag:
   ```bash
   git push && git push --tags
   ```

5. Create a GitHub release manually through the web interface

## Post-Release

After a successful release:

1. Update the README.md if necessary with new features or changes
2. Announce the release in relevant channels
3. Monitor for any issues reported by users

## Hotfixes

For critical issues that need immediate fixing:

1. Create a hotfix branch from the tag:
   ```bash
   git checkout -b hotfix/1.0.2 v1.0.1
   ```

2. Fix the issue and commit the changes
3. Follow the release process above, incrementing the PATCH version
