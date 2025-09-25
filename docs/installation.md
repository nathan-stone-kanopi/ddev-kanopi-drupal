# Installation

This guide will help you install the DDEV Kanopi Drupal Add-on for both existing DDEV projects and projects that don't have DDEV yet.

## Prerequisites

Before installing the add-on, ensure you have:

- [DDEV installed](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/) on your system
- A Drupal project (existing or new)
- Access credentials for your hosting provider (Pantheon or Acquia)

## For Existing DDEV Projects

If you already have DDEV set up in your project:

```bash
# Install the add-on (includes interactive configuration)
ddev add-on get kanopi/ddev-kanopi-drupal

# Restart DDEV to apply changes
ddev restart

# Initialize your development environment
ddev project-init
```

## For Projects Without DDEV

If your project doesn't have DDEV yet, follow these steps:

### Step 1: Install DDEV

!!! tip "DDEV Installation"
    If DDEV is not already installed on your system, install it first:

=== "macOS (Homebrew)"
    ```bash
    # Install DDEV
    brew install ddev/ddev/ddev
    mkcert -install
    ```

=== "macOS (Installer Script)"
    ```bash
    # Using the installer script
    curl -fsSL https://ddev.com/install.sh | bash
    ```

=== "Linux/Windows"
    Follow the detailed instructions at [ddev.readthedocs.io](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/)

### Step 2: Stop Conflicting Tools

!!! warning "Port Conflicts"
    If you're migrating from Docksal or Lando, stop those services first to avoid port conflicts:

=== "Stop Docksal"
    ```bash
    fin system stop
    ```

=== "Stop Lando"
    ```bash
    lando poweroff
    ```

### Step 3: Initialize DDEV in Your Project

Navigate to your existing project directory and configure DDEV:

```bash
cd /path/to/your-drupal-project

# Initialize DDEV configuration
# Match your existing PHP version (8.1, 8.2, 8.3)
ddev config --project-type=drupal --php-version=8.3

# Install the Kanopi add-on
ddev add-on get kanopi/ddev-kanopi-drupal
```

## Interactive Installation Process

During the add-on installation, you'll be prompted to configure various settings:

### 1. Hosting Provider Selection

Choose between Pantheon and Acquia:
```
🌐 Select your hosting platform (pantheon/acquia):
```

The add-on will automatically configure:

=== "Pantheon"
    - **Docroot**: `web` (Pantheon standard)
    - **Database**: MariaDB 10.6
    - **Webserver**: Nginx with proxy configuration

=== "Acquia"
    - **Docroot**: `docroot` (Acquia standard)
    - **Database**: MySQL 5.7
    - **Webserver**: Apache-FPM for compatibility

### 2. Theme Configuration

Configure your custom theme paths:
```
📁 Enter the path to your active Drupal theme (like 'themes/custom/mytheme'):
🎨 Enter your theme name (like 'mytheme'):
```

### 3. Hosting Credentials

=== "Pantheon"
    ```
    🏛️  Please enter your Pantheon Terminus machine token:
    🏛️  Enter your Pantheon project machine name (like 'my-site'):
    🌍 Enter default Pantheon environment for database pulls (dev/test/live) [dev]:
    ```

=== "Acquia"
    ```
    🔷 Please enter your Acquia API Key:
    🔐 Please enter your Acquia API Secret:
    🔷 Enter your Acquia application name (like 'my-app'):
    🌍 Enter default Acquia environment for database pulls (dev/stg/prod) [dev]:
    ```

### 4. Optional Migration Settings

For site migrations, you can optionally configure:
```
📦 Enter migration source project name (optional):
🌍 Enter migration source environment (dev/test/live) (optional):
```

## What Gets Installed

The add-on automatically installs and configures:

### Core Components
- **27 Custom Commands**: Complete development workflow commands
- **Configuration System**: Environment variables and script configuration
- **Provider Integration**: Platform-specific configurations

### DDEV Add-ons
=== "Pantheon Projects"
    - **Redis Add-on**: Object caching for Pantheon compatibility
    - **Solr Add-on**: Search functionality with DDEV configuration
    - **Nginx Proxy**: Automatic asset proxy to Pantheon environments

=== "Acquia Projects"
    - **Memcached Add-on**: Object caching for Acquia compatibility
    - **Solr Add-on**: Search functionality with DDEV configuration
    - **Apache Configuration**: Native Apache-FPM setup

### Development Tools
- **Lefthook**: Git hooks for code quality
- **NVM**: Node.js version management
- **Cypress**: E2E testing framework
- **Critical CSS Tools**: Performance optimization
- **Theme Development**: Asset compilation and build tools

## Post-Installation Setup

After installation, complete these essential setup tasks:

### 1. Configure Global Authentication

=== "Pantheon"
    ```bash
    # Set Pantheon machine token globally
    ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
    ```

    Get your token from: [Pantheon Machine Token](https://dashboard.pantheon.io/machine-token/create)

=== "Acquia"
    ```bash
    # Set Acquia API credentials globally
    ddev config global --web-environment-add=ACQUIA_API_KEY=your_api_key_here
    ddev config global --web-environment-add=ACQUIA_API_SECRET=your_api_secret_here
    ```

    Get your credentials from: [Acquia API Tokens](https://cloud.acquia.com/a/profile/tokens)

### 2. Update Your Drupal Settings

Add DDEV configuration to your `web/sites/default/settings.php`:

```php
/**
 * DDEV Configuration
 * Override hosting provider configurations when in DDEV environment
 */
if (getenv('IS_DDEV_PROJECT') == 'true') {
  // Database configuration
  $databases['default']['default'] = [
    'database' => 'db',
    'username' => 'db',
    'password' => 'db',
    'host' => 'db',
    'driver' => 'mysql',
    'port' => 3306,
    'prefix' => '',
  ];

  // Trusted host patterns
  $settings['trusted_host_patterns'] = [
    '^.+\\.ddev\\.site$',
  ];

  // Development-friendly settings
  $config['system.performance']['css']['preprocess'] = FALSE;
  $config['system.performance']['js']['preprocess'] = FALSE;
  $config['system.logging']['error_level'] = 'verbose';
}
```

### 3. Initialize Your Environment

```bash
# Start DDEV and initialize everything
ddev start
ddev project-init
```

## Verification

Verify your installation is working correctly:

```bash
# Test database refresh
ddev db-refresh

# Test theme tools
ddev theme-install

# Verify hosting provider connection
ddev pantheon-terminus site:list  # For Pantheon
# or
ddev exec acli api:applications:find  # For Acquia

# Test proxy setup (visit your local site and check if assets load)
ddev launch
```

## Manual Configuration

If you need to modify configuration later, you can update environment variables directly:

```bash
# Update theme configuration
ddev config --web-environment-add THEME=themes/custom/your-theme
ddev config --web-environment-add THEMENAME=your-theme-name

# Update hosting configuration
ddev config --web-environment-add HOSTING_PROVIDER=pantheon
ddev config --web-environment-add HOSTING_SITE=your-site-name

# Restart to apply changes
ddev restart
```

## Next Steps

After successful installation:

1. **[Configure your environment](configuration.md)** - Fine-tune your setup
2. **[Set up Drupal settings](drupal-settings-setup.md)** - Configure Drupal for DDEV
3. **[Explore the commands](commands.md)** - Learn about all available commands
4. **[Start theme development](theme-development.md)** - Set up asset compilation