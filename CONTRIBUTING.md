# Contributing to SteamOS Development Bootstrap

Thank you for considering contributing to this project! Here's how you can help.

## Development Process

1. **Fork the repository** and clone it locally
2. **Create a branch** for your feature or bugfix
3. **Make your changes** following the coding guidelines
4. **Test your changes** using the provided Docker test environment
5. **Submit a pull request** with a clear description of the changes

## Testing Your Changes

We use Docker to test the bootstrap script in an isolated environment. To test your changes:

```bash
# Run the test script
./test.sh
```

This will build a Docker container that simulates a SteamOS environment and run the bootstrap script.

Alternatively, you can use docker-compose directly:

```bash
# Build the test container
docker-compose build

# Run the bootstrap script in the container
docker-compose run --rm steamos-test bash -c "echo y | ./bootstrap-steamos.sh"
```

## Coding Guidelines

- Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use ShellCheck to validate your script: `shellcheck bootstrap-steamos.sh`
- Keep the script modular with clear phase separation
- Add proper error handling and user feedback
- Document new features or changes

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the version number following [Semantic Versioning](https://semver.org/)
3. The PR will be merged once it passes all CI checks and receives approval

## Release Process

1. Update the version number in the script
2. Create a new tag following the format `vX.Y.Z`
3. Push the tag to trigger the release workflow
4. The GitHub Actions workflow will automatically create a new release

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a welcoming environment for all contributors

Thank you for your contributions!
