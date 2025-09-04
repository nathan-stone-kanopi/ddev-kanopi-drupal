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
- `ddev refresh [env] [-f]`: Smart database refresh from Pantheon with backup age detection (12-hour threshold)
- `ddev rebuild`: Composer install followed by database refresh
- `ddev open`: Open project URL in browser

### Development Workflow Commands
- `ddev install-theme-tools`: Set up Node.js, NPM, and build tools for theme development
- `ddev npm <command>`: Run NPM commands in theme directory
- `ddev npx <command>`: Run NPX commands in theme directory
- `ddev install-critical-tools`: Install Critical CSS generation tools

### Testing Commands
- `ddev install-cypress`: Install Cypress E2E testing dependencies
- `ddev cypress <command>`: Run Cypress commands with environment support
- `ddev cypress-users`: Create default admin user for Cypress testing
- `ddev testenv <name> [profile]`: Create isolated testing environment

### Drupal Recipe Commands
- `ddev recipe-apply <path>`: Apply Drupal recipe with cache management
- `ddev uuid-rm <path>`: Remove UUIDs from config files (for recipe development)

### Migration and Database Commands
- `ddev migrate-prep-db`: Create secondary database for migrations
- `ddev tickle`: Keep Pantheon environment awake (useful for long migrations)

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

The `ddev refresh` command includes intelligent backup management:
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
ddev add-on get /path/to/ddev-kanopi-pantheon-drupal

# Test removal
ddev add-on remove kanopi-pantheon-drupal
```

### Required Setup
1. Configure Pantheon machine token globally:
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ```

2. The add-on installation now includes interactive prompts for:
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
- after making changes to the install file always test it