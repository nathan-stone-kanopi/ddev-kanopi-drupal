# Installation

This guide will help you install the DDEV Kanopi Drupal Add-on. **This add-on requires a DDEV project to be configured first.**

## Prerequisites

Before installing the add-on, ensure you have:

- [DDEV installed](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/) on your system
- **An existing DDEV project** configured for your hosting provider
- A Drupal project (existing or new)
- Access credentials for your hosting provider (Pantheon or Acquia)

## Installation Steps

Follow these 4 steps to get up and running:

### Step 1: Set Up Your DDEV Project

**Important**: This add-on assumes you have already configured DDEV for your project. Choose your hosting provider setup:

### For Pantheon Projects

```bash
# Clone your Pantheon repository
git clone git@github.com:pantheon-systems/my-site.git
cd my-site

# Initialize DDEV with recommended settings for Pantheon
ddev config --project-type=drupal11 --docroot=web --database=mariadb:10.6
ddev start
```

### For Acquia Projects

```bash
# Clone your Acquia repository
git clone my-app@svn-123.prod.hosting.acquia.com:my-app.git
cd my-app

# Initialize DDEV with recommended settings for Acquia
ddev config --project-type=drupal11 --docroot=docroot --webserver-type=apache-fpm --database=mysql:5.7
ddev start
```

### Alternative: Existing DDEV Projects

If you already have DDEV set up, ensure your configuration matches the requirements:

| Provider | Required Settings |
|----------|-------------------|
| **Pantheon** | `--docroot=web --database=mariadb:10.6` |
| **Acquia** | `--docroot=docroot --webserver-type=apache-fpm --database=mysql:5.7` |

### Step 2: Install the Add-on

Once your DDEV project is properly configured:

```bash
ddev add-on get kanopi/ddev-kanopi-drupal
```

### Step 3: Configure Your Project

Run the interactive configuration wizard:

```bash
ddev project-configure
```

### Step 4: Initialize Development Environment

Complete the project initialization:

```bash
ddev project-init
```

## Setting Up DDEV from Scratch

If you need to set up DDEV for the first time:

### Install DDEV

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

### Stop Conflicting Tools

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

## Configuration Process

After installing the add-on, use the configuration wizard to set up your hosting provider:

### 1. Run the Configuration Wizard

```bash
ddev project-configure
```

The wizard will guide you through:

### 2. Hosting Provider Selection

Choose between Pantheon and Acquia:
```
🏛️ Hosting Provider Configuration:
----------------------------------
Select your hosting provider:
  1. pantheon
  2. acquia
Select option [1]:
```

The configuration wizard will automatically apply platform-specific settings:

=== "Pantheon"
    - **Database**: MariaDB 10.6 (if not already set)
    - **Webserver**: Uses default nginx-fpm
    - **Caching**: Installs Redis add-on
    - **Proxy**: Configures nginx proxy to pantheonsite.io

=== "Acquia"
    - **Database**: MySQL 5.7
    - **Webserver**: Apache-FPM (configured automatically)
    - **Caching**: Installs Memcached add-on
    - **Proxy**: Configures Apache file proxy via .htaccess

### 3. Theme Configuration

Configure your custom theme paths:
```
🎨 Theme Configuration:
----------------------
Theme path (e.g., themes/custom/mytheme):
Theme name/slug (e.g., mytheme):
```

### 4. Hosting Site Settings

=== "Pantheon"
    ```
    🏛️ Pantheon Configuration:
    --------------------------
    Site machine name (e.g., my-site):
    Default environment (dev/test/live) [dev]:
    ```

=== "Acquia"
    ```
    🔷 Acquia Configuration:
    -----------------------
    Application name (e.g., my-app):
    Default environment (dev/stg/prod) [dev]:

    🔗 File Proxy Configuration:
    Proxy URL for missing files (e.g., https://your-site.com):
    ```

### 5. Optional Migration Settings

For site migrations, you can optionally configure:
```
🔄 Migration Settings (optional):
---------------------------------
Source site for migrations (optional):
Source environment [live]:
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
2. **[Explore the commands](commands.md)** - Learn about all available commands
3. **Start theme development** - `ddev theme-watch`
