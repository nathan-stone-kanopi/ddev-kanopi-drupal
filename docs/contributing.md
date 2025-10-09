# Contributing

We welcome contributions to the DDEV Kanopi Drupal Add-on! This guide will help you get started with contributing to the project.

## Ways to Contribute

- **Report bugs** - Found an issue? Let us know!
- **Request features** - Have an idea for improvement?
- **Fix bugs** - Submit pull requests for existing issues
- **Add features** - Implement new functionality
- **Improve documentation** - Help make our docs better
- **Write tests** - Help improve test coverage

## Getting Started

### Prerequisites

- Git
- DDEV v1.22.0 or higher
- Docker and Docker Compose
- Bash (for testing scripts)
- Bats (for running component tests)

### Development Setup

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/yourusername/ddev-kanopi-drupal.git
   cd ddev-kanopi-drupal
   ```

2. **Create a test project**:
   ```bash
   mkdir test-project && cd test-project
   ddev config --project-type=drupal --docroot=web --create-docroot
   ```

3. **Install your local version**:
   ```bash
   ddev add-on get /path/to/your/ddev-kanopi-drupal
   ```

4. **Test your changes**:
   ```bash
   # Run the full integration test
   ./tests/test-install.sh

   # Or run component tests
   bats tests/test.bats
   ```

## Development Guidelines

### Code Style

#### Shell Scripts
- Use `#!/usr/bin/env bash` shebang
- Use `set -e` for error handling
- Include command descriptions and examples in comments
- Follow existing patterns for variable naming and structure

#### Command Structure
All commands should follow this template:

```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e

# Load configuration for web commands
if [[ "${BASH_SOURCE[0]}" == *"/commands/web/"* ]]; then
    source /var/www/html/.ddev/scripts/load-config.sh
    load_kanopi_config
fi

# Command logic here
```

### Command Categories

#### Host Commands (`commands/host/`)
- Execute on the host system outside DDEV containers
- Can interact with local filesystem and external services
- Examples: `project-init`, `cypress-install`, `pantheon-terminus`

#### Web Commands (`commands/web/`)
- Execute inside the DDEV web container
- Have access to Drupal environment and database
- Can use environment variables from configuration
- Examples: `db-refresh`, `theme-build`, `recipe-apply`

### Configuration System

The add-on uses a three-tier configuration system:

1. **Environment Variables**: Stored in `.ddev/config.yaml`
2. **Script Configuration**: Shared via `.ddev/scripts/load-config.sh`
3. **Interactive Configuration**: Via `ddev project-configure`

When adding new configuration:
- Update `install.yaml` for interactive prompts
- Update `load-config.sh` for script access
- Update documentation in `docs/getting-started.md`

### Testing

#### Required Tests

All contributions should include appropriate tests:

1. **Command Tests**: Add command checks to `tests/test.bats`
2. **Integration Tests**: Ensure `tests/test-install.sh` passes
3. **Documentation Tests**: Verify examples work as documented

#### Test Commands

```bash
# Run integration tests (comprehensive)
./tests/test-install.sh

# Run component tests (fast)
bats tests/test.bats

# Run specific test
bats tests/test.bats --filter "install from directory"

# Test in CI environment
DDEV_NONINTERACTIVE=true ./tests/test-install.sh
```

#### Test Environment

The test environment:
- Creates temporary DDEV project with real Drupal
- Tests interactive installation with automated responses
- Validates all commands and configuration
- Cleans up automatically on success
- Preserves environment on failure for debugging

## Contribution Workflow

### 1. Issue First

For significant changes, create an issue first to discuss:
- Bug reports: Use the bug report template
- Feature requests: Describe the use case and proposed solution
- Questions: Ask for clarification on existing functionality

### 2. Development Process

1. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes**:
   - Follow the code style guidelines
   - Add appropriate tests
   - Update documentation

3. **Test thoroughly**:
   ```bash
   # Test your specific changes
   ddev add-on get .
   ddev your-new-command

   # Run full test suite
   ./tests/test-install.sh
   bats tests/test.bats
   ```

4. **Update documentation**:
   - Update `docs/commands.md` for new commands
   - Update `docs/getting-started.md` for new setup steps or variables
   - Update `README.md` if needed
   - Add troubleshooting entries if applicable

### 3. Submission

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new command for recipe management"
   # or
   git commit -m "fix: resolve database refresh timeout issue"
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request**:
   - Use the PR template
   - Describe what your changes do
   - Include testing instructions
   - Reference any related issues

## Pull Request Guidelines

### PR Requirements

- [ ] All tests pass (`./tests/test-install.sh` and `bats tests/test.bats`)
- [ ] Documentation updated (commands, configuration, troubleshooting)
- [ ] Follows existing code style and patterns
- [ ] Includes appropriate tests for new functionality
- [ ] Clear commit messages and PR description

### PR Template

```markdown
## Description
Brief description of changes and motivation

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tests pass locally (`./tests/test-install.sh`)
- [ ] Added tests for new functionality
- [ ] Tested on multiple environments (Pantheon/Acquia)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Documentation updated
- [ ] No breaking changes to existing functionality
```

## Cross-Repository Development

This add-on is part of a family that includes:
- [ddev-kanopi-wp](https://github.com/kanopi/ddev-kanopi-wp) - WordPress add-on
- [ddev-kanopi-drupal](https://github.com/kanopi/ddev-kanopi-drupal) - This repository

### Maintaining Consistency

When contributing to this repository, consider if changes should also be applied to the WordPress add-on:

#### Shared Components
- Command patterns and naming conventions
- Configuration system structure
- Testing framework and patterns
- Documentation organization
- CI/CD workflows

#### Platform-Specific Components
- **Drupal-specific**: Recipe commands, Drupal CLI integration
- **WordPress-specific**: Block creation, WP-CLI integration
- **Hosting providers**: Different platform support

### Cross-Repository Workflow

1. **Assess applicability**: Determine if changes should be mirrored
2. **Coordinate changes**: Make equivalent changes in both repositories
3. **Test both**: Ensure functionality works in both contexts
4. **Maintain compatibility**: Keep command interfaces consistent

## Command Development

### Adding New Commands

1. **Choose command type**:
   - Host command: Runs on local machine
   - Web command: Runs inside DDEV container

2. **Create command file**:
   ```bash
   # For host commands
   touch commands/host/my-new-command
   chmod +x commands/host/my-new-command

   # For web commands
   touch commands/web/my-new-command
   chmod +x commands/web/my-new-command
   ```

3. **Use command template**:
   ```bash
   #!/usr/bin/env bash

   ## Description: What this command does
   ## Usage: my-new-command [options]
   ## Example: "ddev my-new-command --flag value"

   set -e

   # Command logic here
   ```

4. **Add to install.yaml**:
   - Add removal line in `removal_action` section
   - Update command count in descriptions

5. **Add tests**:
   - Add command test to `tests/test.bats`
   - Test in integration test

6. **Update documentation**:
   - Add to `docs/commands.md`
   - Update `README.md` command overview
   - Add examples and usage instructions

### Command Best Practices

- **Error handling**: Use `set -e` and check return codes
- **User feedback**: Provide clear output and progress indicators
- **Configuration**: Use shared configuration system
- **Help text**: Include usage examples and descriptions
- **Compatibility**: Ensure commands work across platforms

## Documentation

### Documentation Structure

- `docs/` - MkDocs documentation source
- `mkdocs.yml` - MkDocs configuration
- `README.md` - Simplified overview with links to full docs

### Writing Documentation

- Use clear, concise language
- Include code examples for all procedures
- Use admonitions for warnings and tips
- Test all code examples
- Keep navigation intuitive

### Building Documentation

```bash
# Install MkDocs
pip install mkdocs-material mkdocs-git-revision-date-localized-plugin

# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

## Release Process

### Version Management

Releases are managed by maintainers using semantic versioning:
- `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- Breaking changes increment MAJOR
- New features increment MINOR
- Bug fixes increment PATCH

### Release Checklist

1. Update version references in documentation
2. Run full test suite across environments
3. Update changelog
4. Create GitHub release with notes
5. Update documentation site

## Community

### Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Requests**: Code contributions and reviews

### Code of Conduct

We follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/). Please be respectful and inclusive in all interactions.

## Getting Help

### For Contributors

- Review existing issues and pull requests
- Check the troubleshooting guide
- Ask questions in GitHub Discussions
- Reach out to maintainers for major changes

### For Users

- Use GitHub Issues for bug reports
- Check documentation first
- Provide clear reproduction steps
- Include debug information

## Recognition

Contributors are recognized in:
- GitHub Contributors page
- Release notes for significant contributions
- Documentation credits

Thank you for contributing to the DDEV Kanopi Drupal Add-on!