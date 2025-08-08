# Changelog

All notable changes to the DDEV Kanopi Pantheon Drupal add-on will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-08

### Added
- Initial release of ddev-kanopi-pantheon-drupal add-on
- 17 custom DDEV commands for Drupal development workflow
- Enhanced Pantheon provider with smart backup management
- Complete theme development toolchain with Node.js/NPM support
- Cypress E2E testing integration
- Drupal 11 Recipe support
- Migration and database utilities
- Comprehensive documentation and setup guides

### Features

#### Development Workflow Commands
- `ddev init` - Complete project initialization
- `ddev rebuild` - Composer install + database refresh  
- `ddev refresh` - Smart database refresh with backup management
- `ddev testenv` - Create isolated testing environments

#### Theme Development
- `ddev install-theme-tools` - Node.js/NPM setup
- `ddev install-critical-tools` - Critical CSS generation
- `ddev npm` / `ddev npx` - Package management in theme directory

#### Testing Integration  
- `ddev install-cypress` - E2E testing setup
- `ddev cypress` - Run Cypress commands
- `ddev cypress-users` - Create test users

#### Drupal Recipe Support
- `ddev recipe-apply` - Apply recipes with cache management

#### Utilities
- `ddev migrate-prep-db` - Migration database setup
- `ddev uuid-rm` - Config file cleanup
- `ddev tickle` - Keep Pantheon environments awake
- `ddev open` / `ddev phpmyadmin` - Quick access tools

### Enhanced Pantheon Integration
- Smart backup age detection (12-hour threshold)
- Multi-environment support (dev, test, live, multidev)
- Force backup flag support
- Improved error handling and user feedback
- Terminus authentication management