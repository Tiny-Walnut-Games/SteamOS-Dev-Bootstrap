# CI/CD Pipeline Documentation

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the SteamOS Development Bootstrap project.

## Pipeline Overview

Our CI/CD pipeline is implemented using GitHub Actions and consists of the following stages:

1. **Security Scanning**: Checks for security vulnerabilities and issues
2. **Validation**: Verifies script syntax and version consistency
3. **Testing**: Runs the bootstrap script in Docker containers
4. **Release**: Creates GitHub releases for tagged versions

## Security Scanning Stage

The security scanning stage performs comprehensive security checks:

- **ShellCheck Analysis**: Analyzes shell scripts for bugs and vulnerabilities
- **Secret Detection**: Scans for accidentally committed secrets
- **Unsafe Pattern Detection**: Identifies pipe-to-shell patterns and other unsafe practices
- **Insecure Certificate Validation**: Checks for disabled certificate validation
- **Credential Detection**: Looks for potential hardcoded credentials

### Security Exceptions

Some test files contain patterns that would normally fail security scanning. These exceptions are documented in [SECURITY.md](SECURITY.md#security-exceptions).

## Validation Stage

The validation stage ensures the script is correctly formatted and versioned:

- **Syntax Checking**: Verifies shell script syntax
- **Version Consistency**: Ensures tag version matches script version (for releases)

## Testing Stage

The testing stage runs the bootstrap script in Docker containers:

- **Basic Testing**: Runs verification-only mode
- **Full Testing**: Runs the complete bootstrap process

The Docker container simulates a SteamOS environment to test script functionality.

## Release Stage

The release stage creates GitHub releases for tagged versions:

- **Changelog Generation**: Automatically generates a changelog from commit messages
- **Asset Packaging**: Includes bootstrap script and version file
- **Release Notes**: Provides installation instructions and changelog

## Local Testing

You can run the pipeline locally using Docker:

```bash
# Run security scan
./test.sh --security-scan

# Run basic verification test
./test.sh --verify-only

# Run full test
./test.sh --full
```

For more advanced testing, use docker-compose:

```bash
# Run security scan
docker-compose -f docker-compose.test.yml run security-scan

# Run basic test
docker-compose -f docker-compose.test.yml run steamos-test
```

## Security Considerations

The CI/CD pipeline includes several security measures:

- **Minimal Permissions**: Each job uses only the permissions it needs
- **Dependency Pinning**: Docker images use specific version tags
- **Secret Management**: No secrets are hardcoded in workflow files
- **Security Scanning**: Automated checks for security issues

For more information on security practices, see [SECURITY.md](SECURITY.md).

## Troubleshooting

If the pipeline fails, check the following:

1. **Security Scan Failures**: Review the security scan logs for issues
2. **Validation Failures**: Check script syntax and version consistency
3. **Test Failures**: Examine test logs for errors
4. **Docker Issues**: Verify Docker configuration and image building

## Maintenance

To maintain the CI/CD pipeline:

1. Keep GitHub Actions workflows updated
2. Update Docker image versions regularly
3. Review and update security scanning patterns
4. Test pipeline changes in a development branch before merging
