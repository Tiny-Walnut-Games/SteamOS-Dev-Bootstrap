# Security Guidelines

This document outlines security practices for the SteamOS Development Bootstrap project.

## Secure Installation

We offer two installation methods:

### Option 1: Download and verify before running (Recommended)

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh -o bootstrap-steamos.sh

# Review the script content
less bootstrap-steamos.sh

# Execute after review
bash bootstrap-steamos.sh
```

### Option 2: Direct execution (Convenient but less secure)

```bash
curl -fsSL https://raw.githubusercontent.com/Tiny-Walnut-Games/SteamOS-Dev-Bootstrap/main/bootstrap-steamos.sh | bash
```

**Note:** The direct execution method doesn't allow you to review the script before execution. Only use this method if you trust the source.

## CI/CD Secrets Management

This project uses GitHub Actions for CI/CD. Secrets are managed through GitHub's repository secrets feature.

### Required Secrets

- `DOCKERHUB_USERNAME`: DockerHub username for publishing images (if applicable)
- `DOCKERHUB_TOKEN`: DockerHub access token (if applicable)

### Secret Usage Guidelines

1. Never hardcode secrets in any files
2. Use GitHub's secret management for CI/CD secrets
3. For local development, use environment variables or `.env` files (excluded from git)
4. Rotate secrets regularly according to your organization's policy

## Security Scanning

The CI/CD pipeline includes automated security scanning:

1. **ShellCheck**: Analyzes shell scripts for common bugs and vulnerabilities
2. **detect-secrets**: Scans for accidentally committed secrets
3. **Custom pattern detection**: Identifies unsafe practices like pipe-to-shell patterns

## Reporting Security Issues

If you discover a security vulnerability, please report it by:

1. **DO NOT** create a public GitHub issue
2. Email security@your-domain.com with details
3. Include steps to reproduce the vulnerability
4. We'll acknowledge receipt within 48 hours

## Security Best Practices

When contributing to this project:

1. Always validate user input
2. Use HTTPS for all downloads
3. Verify file integrity with checksums when possible
4. Avoid pipe-to-shell patterns (`curl | bash`)
5. Use specific version tags for dependencies
6. Follow the principle of least privilege

## Security Exceptions

Some test scripts may contain patterns that would normally fail security scanning (like pipe-to-shell patterns). These are documented exceptions for testing purposes only and should not be used in production code.

The following files have documented exceptions:
- `test/ubuntu-adaptation.sh`: Contains pipe-to-shell patterns for installing Node.js and Rust in test environments
