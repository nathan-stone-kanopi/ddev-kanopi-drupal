# DDEV Kanopi Drupal Add-on

[![tests](https://github.com/kanopi/ddev-kanopi-drupal/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/kanopi/ddev-kanopi-drupal/actions/workflows/test.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/kanopi/ddev-kanopi-drupal)](https://github.com/kanopi/ddev-kanopi-drupal/commits)
[![release](https://img.shields.io/github/v/release/kanopi/ddev-kanopi-drupal)](https://github.com/kanopi/ddev-kanopi-drupal/releases/latest)
![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

A comprehensive DDEV add-on that provides Kanopi's battle-tested workflow for Drupal development. This add-on includes complete tooling for modern Drupal development with multi-provider hosting support.

## Features

This add-on provides:

- **27 Custom Commands**: Complete Drupal development workflow with namespaced commands
- **Multi-Provider Hosting**: Support for Pantheon and Acquia hosting platforms
- **Recipe Development**: Tools for Drupal 11 recipe creation and management
- **Theme Development**: Node.js, NPM, and build tools with file watching
- **Testing Framework**: Cypress E2E testing with user management
- **Database Management**: Smart refresh system with 12-hour backup detection
- **Critical CSS Tools**: Performance optimization with critical path CSS generation
- **Migration Utilities**: Tools for site migrations and database management
- **Security & Performance**: Platform-specific configurations and optimization
- **Services Integration**: PHPMyAdmin, Redis/Memcached, and Solr via official DDEV add-ons
- **Environment Configuration**: Clean configuration system using environment variables

## Quick Start

Get started with the add-on in 4 simple steps:

### Prerequisites

First, set up DDEV for your project with the appropriate settings for your hosting provider:

=== "Pantheon"

    ```bash
    # Initialize DDEV project for Pantheon
    ddev config --project-type=drupal --docroot=web --create-docroot
    ddev start
    ```

=== "Acquia"

    ```bash
    # Initialize DDEV project for Acquia
    ddev config --project-type=drupal --docroot=docroot --webserver-type=apache-fpm --database=mysql:5.7
    ddev start
    ```

### Installation Steps

1. **Add DDEV** (complete the prerequisites above first)

2. **Install the Add-on**
   ```bash
   ddev add-on get kanopi/ddev-kanopi-drupal
   ```

3. **Configure Your Project**
   ```bash
   ddev project-configure
   ```

4. **Initialize Development Environment**
   ```bash
   ddev project-init
   ```

## Documentation Structure

This documentation is organized into several main sections:

### Getting Started
- **[Installation](installation.md)** - How to install and set up the add-on
- **[Configuration](configuration.md)** - Configure hosting providers and environment

### Commands
- **[Command Reference](commands.md)** - Complete list of all 27 commands

### Hosting Providers
- **[Provider Setup](hosting-providers.md)** - General hosting provider information

### Advanced Topics
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions
- **[Contributing](contributing.md)** - How to contribute to the project

## Platform Support

### Pantheon Integration
- **Nginx Configuration**: Automatic proxy setup for missing assets
- **Terminus Integration**: Full Pantheon API access with machine token authentication
- **Smart Backups**: 12-hour backup age detection with automatic refresh
- **Redis Caching**: Optimized object caching for Pantheon environments
- **Multidev Support**: Work with any Pantheon environment including multidevs

### Acquia Integration
- **Apache-FPM Configuration**: Native Apache setup matching Acquia Cloud
- **Acquia CLI Integration**: Full Acquia Cloud API access
- **File Proxy**: Apache .htaccess-based proxy for missing files
- **Memcached Caching**: Optimized caching for Acquia environments
- **Multi-database Support**: Handle complex Acquia database setups

## Architecture Overview

The add-on is built around a modular architecture with clear separation between host and web commands:

### Command Structure
- **Host Commands (13)**: Execute on the host system outside containers
- **Web Commands (14)**: Execute inside the DDEV web container

### Configuration System
- **Environment Variables**: Stored in `.ddev/config.yaml` for container access
- **Script Configuration**: Shared configuration via `.ddev/scripts/load-config.sh`
- **Provider-Specific**: Separate configuration paths for Pantheon and Acquia

### Smart Refresh System
- **Pantheon**: Uses Terminus API for backup age detection and download
- **Acquia**: Uses Acquia CLI for database synchronization
- **Automatic Detection**: 12-hour threshold for forcing new backups
- **Post-refresh Actions**: Automatic user creation and cache clearing

## Quick Reference

### Daily Development Workflow
```bash
# Start your development day
ddev project-init                 # Initialize everything

# Or run individual commands
ddev start                        # Start DDEV
ddev db-refresh                   # Get latest database
ddev theme-install                # Set up theme tools (first time)
ddev theme-watch                  # Start theme development
```

### Testing Workflow
```bash
# Set up testing environment
ddev cypress-install              # Install Cypress (first time)
ddev cypress-users                # Create test users
ddev cypress-run open             # Open Cypress UI

# Or run headless tests
ddev cypress-run run              # Run all tests
```

### Recipe Development
```bash
# Work with Drupal recipes
ddev recipe-apply ../recipes/my-recipe     # Apply a recipe
ddev recipe-unpack drupal/example_recipe   # Unpack packaged recipe
ddev recipe-uuid-rm config/sync            # Clean UUIDs for development
```

### Database & Migration
```bash
# Database operations
ddev db-refresh live -f           # Force refresh from live environment
ddev db-prep-migrate               # Set up secondary database for migrations
ddev pantheon-tickle              # Keep environment awake during long operations
```

## Next Steps

1. **[Install the add-on](installation.md)** - Get started with installation
2. **[Configure your hosting provider](configuration.md)** - Set up Pantheon or Acquia
3. **[Explore the commands](commands.md)** - Learn about all available commands