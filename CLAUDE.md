# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DDEV add-on that provides Kanopi's battle-tested workflow for Drupal development with Pantheon hosting. The add-on includes 17 custom commands, enhanced Pantheon provider integration, and complete tooling for modern Drupal development.

## Architecture

### Command Structure
Commands are organized into two categories:
- **Host commands** (`commands/host/`): Execute on the host system outside containers
- **Web commands** (`commands/web/`): Execute inside the DDEV web container

### Core Components
- `install.yaml`: Add-on installation configuration and post-install actions
- `commands/`: Custom DDEV commands for development workflow
- `providers/`: Enhanced Pantheon provider configuration (not in this repo but created during installation)

## Common Development Commands

### Essential Commands
- `ddev init`: Complete project initialization with dependencies, Lefthook, NVM, Cypress, and database refresh
- `ddev db:refresh [env] [-f]`: Smart database refresh from Pantheon with backup age detection (12-hour threshold)
- `ddev db:rebuild`: Composer install followed by database refresh
- `ddev open`: Open project URL in browser

### Development Workflow Commands
- `ddev theme:install`: Set up Node.js, NPM, and build tools for theme development
- `ddev theme:npm <command>`: Run NPM commands in theme directory
- `ddev theme:npx <command>`: Run NPX commands in theme directory
- `ddev critical:install`: Install Critical CSS generation tools
- `ddev critical:run`: Run Critical CSS generation
- `ddev theme:watch`: Start theme development with file watching
- `ddev theme:build`: Build production theme assets

### Testing Commands
- `ddev cypress:install`: Install Cypress E2E testing dependencies
- `ddev cypress:run <command>`: Run Cypress commands with environment support
- `ddev cypress:users`: Create default admin user for Cypress testing
- `ddev pantheon:testenv <name> [type]`: Create isolated testing environment

### Drupal Recipe Commands
- `ddev recipe:apply <path>`: Apply Drupal recipe with cache management
- `ddev recipe:uuid-rm <path>`: Remove UUIDs from config files (for recipe development)

### Migration and Database Commands
- `ddev db:prep-migrate`: Create secondary database for migrations
- `ddev pantheon:tickle`: Keep Pantheon environment awake (useful for long migrations)
- `ddev pantheon:terminus <command>`: Run Terminus commands for Pantheon integration

### Utility Commands
- `ddev phpmyadmin`: Launch PhpMyAdmin

## Environment Variables

Key environment variables configured in `.ddev/.env.web`:
- `THEME`: Path to custom theme directory (e.g., `themes/custom/themename`)
- `THEMENAME`: Theme name for development tools
- `hostingsite`: Pantheon site identifier
- `hostingenv`: Current environment (dev, test, live)
- `MIGRATE_DB_SOURCE`: Source database for migrations
- `MIGRATE_DB_ENV`: Source environment for migrations

Pantheon configuration in `.ddev/providers/pantheon.yaml`:
```yaml
environment_variables:
  project: your-site-name.env
```

## Smart Refresh System

The `ddev db:refresh` command includes intelligent backup management:
- Automatically detects backup age (12-hour threshold)
- Uses `-f` flag to force new backup creation
- Supports any Pantheon environment (dev, test, live, multidev)
- Includes automatic Cypress user creation after refresh

## Command Development Guidelines

### Host Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"
## OSTypes: darwin,linux,windows

set -e
# Command logic here
```

### Web Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e
# Command logic here
```

## Installation and Testing

### Local Development
```bash
# Test add-on installation
ddev add-on get /path/to/ddev-kanopi-drupal

# Test removal
ddev add-on remove kanopi-pantheon-drupal
```

### Testing Framework
The project includes comprehensive testing:

#### Official DDEV Testing (CI)
Uses `ddev/github-action-add-on-test@v2` for standardized add-on validation in GitHub Actions.

#### Bats Tests (Component Testing)
```bash
# Run bats tests locally
bats tests/test.bats

# Run specific test
bats tests/test.bats --filter "install from directory"
```

#### Integration Testing (End-to-End)
```bash
# Run comprehensive integration test
./tests/test-install.sh
```

### Required Setup
1. Configure Pantheon machine token globally:
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ```

2. The add-on installation includes interactive prompts for:
   - **THEME**: Path to active Drupal theme (e.g., `themes/custom/mytheme`)
   - **THEMENAME**: Theme name for development tools
   - **PANTHEON_SITE**: Pantheon project machine name (required)
   - **PANTHEON_ENV**: Default environment for database pulls (defaults to `dev`)
   - **MIGRATE_DB_SOURCE**: Migration source project (optional)
   - **MIGRATE_DB_ENV**: Migration source environment (optional)

3. Configure Pantheon project in `.ddev/providers/pantheon.yaml` (if not using interactive setup)
4. Run `ddev restart` and `ddev init`

## Dependencies

The add-on automatically installs and configures:
- Lefthook for git hooks
- NVM for Node.js version management
- Cypress for E2E testing
- Terminus for Pantheon API access
- Theme development tools (Node.js, NPM)
- Critical CSS generation tools
- Redis add-on for caching
- Solr add-on for search functionality

## Cross-Repository Development

**IMPORTANT**: When working on this Drupal add-on, you should also work on the companion WordPress add-on (`ddev-kanopi-wp`) to maintain consistency between both projects.

### Maintaining Feature Parity
Both add-ons should maintain feature parity where applicable:
- **Shared commands**: Database, theme, testing, and utility commands should have identical functionality
- **Configuration patterns**: Environment variables, file structures, and naming conventions should align
- **Documentation**: README files, command help text, and examples should be consistent
- **CI/CD**: Both projects should have identical GitHub Actions and CircleCI configurations

### Development Workflow
When making changes to this repository:
1. **Assess applicability**: Determine if the change should also be applied to the WordPress add-on
2. **Mirror changes**: If applicable, make equivalent changes in both repositories
3. **Test both**: Ensure changes work correctly in both Drupal and WordPress contexts
4. **Update documentation**: Keep README and CLAUDE.md files synchronized
5. **Maintain aliases**: Preserve backward compatibility in both add-ons

### Platform-Specific Differences
While maintaining consistency, respect platform differences:
- **Drupal-specific**: Recipe commands (`recipe:apply`, `recipe:uuid-rm`)
- **WordPress-specific**: Block creation (`theme:create-block`), admin user management (`wp:restore-admin-user`)
- **Hosting providers**: Both support Pantheon, but WordPress also supports WPEngine and Kinsta
- **File structures**: Drupal uses different directory conventions than WordPress

### Repository Locations
- **Drupal add-on**: https://github.com/kanopi/ddev-kanopi-drupal
- **WordPress add-on**: https://github.com/kanopi/ddev-kanopi-wp

## Testing Notes
- Always test changes to install.yaml thoroughly
- Use bats tests for quick validation during development
- Run integration tests before major releases
- Tests pre-configure environment variables to avoid interactive prompts
- Test changes in both add-ons when making cross-repository updates