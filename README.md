# 🌲 SteamOS Development Environment Bootstrap

A comprehensive script to transform a fresh SteamOS installation into a complete development environment with all essential tools, development toolchains, and applications.

## 🚀 Quick Start

Run this on your SteamOS device:

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

## 🔧 Features

- **System Verification**: Ensures you're running on SteamOS 3.x
- **Package Management**: Updates system and installs essential packages
- **Development Toolchains**: Python, Node.js, Java, Rust, Go, .NET, and C/C++ build tools
- **Git & SSH Setup**: Configures Git identity and SSH keys
- **Flatpak Applications**: Installs development tools like VS Code, JetBrains IDEs, and more
- **Container Tools**: Sets up Docker and Podman for containerized development
- **Shell Environment**: Configures your shell with useful aliases and settings

## 🧪 Development & Testing

This project uses a comprehensive CI/CD pipeline to ensure the bootstrap script works correctly.

### Local Testing

You can test the script locally using Docker:

```bash
# Run full test
./test.sh

# Run verification-only test
./test.sh --verify-only

# Run quick test
./test.sh --quick

# Run security scan
./test.sh --security-scan

# Skip rebuilding Docker image
./test.sh --skip-build
```

### CI/CD Pipeline

The CI/CD pipeline consists of the following stages:

1. **Security Scan**: Performs comprehensive security analysis
   - Checks for hardcoded credentials and secrets
   - Identifies insecure practices like certificate validation bypassing
   - Detects unsafe pipe-to-bash patterns
   - Scans for potential security vulnerabilities

2. **Validation**: Uses ShellCheck to ensure script quality
   - Checks for syntax errors and best practices
   - Verifies version consistency on tag pushes

3. **Testing**: Runs the script in a Docker container that simulates a SteamOS environment
   - Basic test: Verifies system detection and initial phases
   - Full test: Attempts to run through all installation phases

4. **Release**: Automatically creates GitHub releases when version tags are pushed
   - Generates changelog from commit history
   - Attaches bootstrap script to the release
   - Creates formatted release notes with secure installation instructions

For more details, see [CI_CD_PIPELINE.md](docs/CI_CD_PIPELINE.md).

### Security Considerations

This project takes security seriously. For details on our security practices and guidelines, see [SECURITY.md](docs/SECURITY.md).

### Release Process

To create a new release:

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

The CI/CD pipeline will automatically create a GitHub release.

## 📝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
