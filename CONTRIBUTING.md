# Contributing to DDEV Kanopi Pantheon Drupal Add-on

Thank you for your interest in contributing to the DDEV Kanopi Pantheon Drupal add-on! This guide will help you get started.

## Development Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/kanopi/ddev-kanopi-pantheon-drupal.git
   cd ddev-kanopi-pantheon-drupal
   ```

2. **Test locally**:
   ```bash
   # Install the add-on locally for testing
   ddev add-on get /path/to/ddev-kanopi-pantheon-drupal
   
   # Or test with an existing project
   cd your-drupal-project
   ddev add-on get /path/to/ddev-kanopi-pantheon-drupal
   ```

## Project Structure

```
ddev-kanopi-pantheon-drupal/
├── install.yaml                    # Add-on installation configuration
├── README.md                      # Main documentation
├── CHANGELOG.md                   # Version history
├── CONTRIBUTING.md                # This file
├── LICENSE                        # MIT license
├── commands/                      # Custom DDEV commands
│   ├── host/                     # Commands that run on host system
│   │   ├── cypress               # Cypress testing
│   │   ├── cypress-users         # Create test users
│   │   ├── init                  # Project initialization
│   │   ├── install-cypress       # Install Cypress
│   │   ├── open                  # Open browser
│   │   ├── phpmyadmin           # Database admin
│   │   ├── rebuild              # Composer + DB refresh
│   │   ├── refresh              # Smart DB refresh
│   │   └── testenv              # Testing environment
│   └── web/                      # Commands that run in web container
│       ├── install-critical-tools # Critical CSS tools
│       ├── install-theme-tools   # Theme development setup
│       ├── migrate-prep-db       # Migration database
│       ├── npm                   # NPM in theme directory
│       ├── npx                   # NPX in theme directory
│       ├── recipe-apply          # Apply Drupal recipes
│       ├── tickle                # Keep Pantheon awake
│       └── uuid-rm               # Clean config UUIDs
├── providers/
│   └── pantheon.yaml            # Enhanced Pantheon provider
└── config/
    └── config.kanopi-pantheon.yaml # Default configuration
```

## Adding New Commands

### Host Commands
Host commands run on the host system (outside containers). Place them in `commands/host/`.

**Template**:
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"
## OSTypes: darwin,linux,windows

# Abort if anything fails
set -e

# Your command logic here
```

### Web Commands
Web commands run inside the web container. Place them in `commands/web/`.

**Template**:
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

# Abort if anything fails
set -e

# Your command logic here
```

## Testing Changes

1. **Test installation**:
   ```bash
   ddev add-on get /path/to/your-modified-add-on
   ```

2. **Test commands**:
   ```bash
   ddev your-new-command
   ```

3. **Test removal**:
   ```bash
   ddev add-on remove kanopi-pantheon-drupal
   ```

## Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Update documentation** (README.md, CHANGELOG.md)
6. **Commit with descriptive messages**:
   ```bash
   git commit -m "Add new command for [specific functionality]"
   ```
7. **Push and create a pull request**

## Code Style

- **Shell scripts**: Follow standard bash practices
- **Comments**: Use `## Description:` format for command descriptions
- **Error handling**: Use `set -e` and proper error messages
- **User feedback**: Include helpful output with emojis for visual clarity

## Documentation

- Update README.md for new features
- Add entries to CHANGELOG.md
- Include examples in command descriptions
- Document any new environment variables

## Support

For questions or help with development:
- Open an issue on GitHub
- Contact the Kanopi team
- Review existing commands for patterns and examples