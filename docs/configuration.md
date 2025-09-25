# Configuration

The DDEV Kanopi Drupal Add-on uses a comprehensive configuration system that supports multiple hosting providers and maintains clean separation between different configuration concerns.

## Configuration Overview

The add-on uses a three-tier configuration system:

1. **Interactive Configuration**: Initial setup via `ddev project-configure`
2. **Environment Variables**: Stored in `.ddev/config.yaml` for container access
3. **Script Configuration**: Shared via `.ddev/scripts/load-config.sh` for command scripts

## Quick Configuration

For most users, the interactive configuration wizard provides everything needed:

```bash
ddev project-configure
```

This wizard will:
- Detect your hosting provider
- Configure theme paths and names
- Set up hosting credentials and environments
- Configure optional migration settings

## Configuration Storage

### DDEV Environment Variables

Configuration is stored in `.ddev/config.yaml` in the `web_environment` section:

```yaml
web_environment:
- HOSTING_PROVIDER=pantheon
- THEME=themes/custom/mytheme
- THEMENAME=mytheme
- HOSTING_SITE=my-site
- HOSTING_ENV=dev
```

### Script Configuration

Commands can access configuration via the shared script:

```bash
# In any web command
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Variables are now available
echo $HOSTING_PROVIDER
echo $THEME
```

## Configuration Variables

### Universal Variables (All Providers)

These variables are used regardless of your hosting provider:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `HOSTING_PROVIDER` | Platform identifier | `pantheon`, `acquia` | Yes |
| `THEME` | Path to custom theme directory | `themes/custom/mytheme` | Yes |
| `THEMENAME` | Theme name for development tools | `mytheme` | Yes |
| `HOSTING_SITE` | Site identifier on hosting platform | Varies by provider | Yes |
| `HOSTING_ENV` | Default environment for database pulls | `dev`, `test`, `live` | Yes |

### Migration Variables (Optional)

For site migrations, you can configure source database information:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `MIGRATE_DB_SOURCE` | Source site for migrations | `old-site-name` | No |
| `MIGRATE_DB_ENV` | Source environment for migrations | `live` | No |

## Provider-Specific Configuration

### Pantheon Configuration

For Pantheon projects, configure these variables:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `HOSTING_SITE` | Pantheon site machine name | `my-drupal-site` | Yes |
| `HOSTING_ENV` | Default environment | `dev`, `test`, `live` | Yes |
| `MIGRATE_DB_SOURCE` | Migration source site | `source-site` | No |
| `MIGRATE_DB_ENV` | Migration source environment | `live` | No |

#### Global Pantheon Authentication

Set your Terminus machine token globally (required for all Pantheon operations):

```bash
# Set globally for all DDEV projects
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
```

!!! tip "Getting Your Token"
    Generate your Pantheon machine token at: [https://dashboard.pantheon.io/machine-token/create](https://dashboard.pantheon.io/machine-token/create)

#### Pantheon Automatic Configuration

When you choose Pantheon, the add-on automatically configures:
- **Docroot**: `web` (Pantheon standard)
- **Database**: MariaDB 10.6
- **Webserver**: Nginx with proxy configuration
- **Caching**: Redis add-on for object caching

### Acquia Configuration

For Acquia projects, configure these variables:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `HOSTING_SITE` | Acquia application UUID | `a47ac10b-58cc-4372-a567-0e02b2c3d479` | Yes |
| `HOSTING_ENV` | Default environment | `dev`, `stg`, `prod` | Yes |
| `APACHE_FILE_PROXY` | Proxy URL for missing files | `https://mysite.acquia.com` | No |

#### Global Acquia Authentication

Set your Acquia API credentials globally (required for all Acquia operations):

```bash
# Set API credentials globally for all DDEV projects
ddev config global --web-environment-add=ACQUIA_API_KEY=your_api_key_here
ddev config global --web-environment-add=ACQUIA_API_SECRET=your_api_secret_here
```

!!! tip "Getting Your Credentials"
    Generate your Acquia API credentials at: [https://cloud.acquia.com/a/profile/tokens](https://cloud.acquia.com/a/profile/tokens)

#### Acquia Automatic Configuration

When you choose Acquia, the add-on automatically configures:
- **Docroot**: `docroot` (Acquia standard)
- **Database**: MySQL 5.7
- **Webserver**: Apache-FPM for compatibility
- **Caching**: Memcached add-on for object caching

## Manual Configuration

### Updating Variables

You can update configuration variables manually using DDEV commands:

```bash
# Update hosting provider
ddev config --web-environment-add HOSTING_PROVIDER=pantheon

# Update theme configuration
ddev config --web-environment-add THEME=themes/custom/new-theme
ddev config --web-environment-add THEMENAME=new-theme

# Update site information
ddev config --web-environment-add HOSTING_SITE=my-new-site
ddev config --web-environment-add HOSTING_ENV=test

# Apply changes
ddev restart
```

### Removing Variables

To remove a variable:

```bash
# Remove migration configuration
ddev config --web-environment-remove MIGRATE_DB_SOURCE
ddev config --web-environment-remove MIGRATE_DB_ENV

# Apply changes
ddev restart
```

### Viewing Current Configuration

Check your current configuration:

```bash
# View all environment variables
ddev exec env | grep -E "(HOSTING|THEME|MIGRATE)"

# View specific variables
ddev exec printenv HOSTING_PROVIDER
ddev exec printenv THEME
ddev exec printenv HOSTING_SITE
```

## Advanced Configuration

### Custom Script Configuration

For advanced use cases, you can modify the shared configuration script at `.ddev/scripts/load-config.sh`:

```bash
# Load configuration in your custom scripts
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Access any variable
if [[ "$HOSTING_PROVIDER" == "pantheon" ]]; then
    echo "Using Pantheon configuration"
elif [[ "$HOSTING_PROVIDER" == "acquia" ]]; then
    echo "Using Acquia configuration"
fi
```

### Platform-Specific Configurations

#### Pantheon Nginx Configuration

For Pantheon projects, nginx configuration is automatically created at `.ddev/nginx_full/nginx-site.conf` with:
- Automatic proxy to `$HOSTING_ENV-$HOSTING_SITE.pantheonsite.io`
- Optimized caching headers
- Clean URL handling

#### Acquia Apache Configuration

For Acquia projects, Apache configuration includes:
- File proxy rules in `.htaccess` for missing assets
- Apache-FPM compatibility settings
- Rewrite rules for clean URLs

### CI/CD Configuration

For continuous integration environments, the add-on automatically detects CI and uses default values:

```bash
# CI environment variables automatically set defaults
CI=true
GITHUB_ACTIONS=true
DDEV_NONINTERACTIVE=true
```

When these are detected, the add-on skips interactive prompts and uses sensible defaults.

## Configuration Troubleshooting

### Common Issues

#### Missing Configuration
```bash
# Check if variables are set
ddev exec env | grep HOSTING

# If missing, run configuration wizard
ddev project-configure
```

#### Authentication Issues
```bash
# Check Pantheon token
ddev exec printenv TERMINUS_MACHINE_TOKEN

# Check Acquia credentials
ddev exec printenv ACQUIA_API_KEY
ddev exec printenv ACQUIA_API_SECRET
```

#### Theme Path Issues
```bash
# Verify theme path exists
ddev exec ls -la $THEME

# Update if necessary
ddev config --web-environment-add THEME=correct/path/to/theme
ddev restart
```

### Validation Commands

Validate your configuration:

```bash
# Test hosting provider connection
ddev pantheon-terminus site:list  # For Pantheon
ddev exec acli api:applications:find  # For Acquia

# Test theme configuration
ddev theme-install

# Test database refresh
ddev db-refresh --help
```

## Configuration Best Practices

### 1. Use the Configuration Wizard

Always start with the interactive wizard:
```bash
ddev project-configure
```

### 2. Set Global Credentials Once

Set hosting provider credentials globally to avoid repeating them:
```bash
# Pantheon (once per machine)
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token

# Acquia (once per machine)
ddev config global --web-environment-add=ACQUIA_API_KEY=your_key
ddev config global --web-environment-add=ACQUIA_API_SECRET=your_secret
```

### 3. Document Project-Specific Settings

Document your project's configuration in your project README:
```markdown
## DDEV Configuration

- **Hosting Provider**: Pantheon
- **Site Name**: my-drupal-site
- **Default Environment**: dev
- **Theme Path**: themes/custom/mytheme
```

### 4. Version Control Configuration

Include relevant configuration in version control:
- `.ddev/config.yaml` (with environment variables)
- `.ddev/nginx_full/nginx-site.conf` (for Pantheon)
- Custom scripts in `.ddev/scripts/`

Exclude sensitive information:
- Never commit API tokens or machine tokens
- Use global configuration for credentials

## Next Steps

After configuration:

1. **[Set up Drupal settings](drupal-settings-setup.md)** - Configure Drupal for DDEV
2. **[Learn about hosting providers](hosting-providers.md)** - Platform-specific guides
3. **[Explore commands](commands.md)** - Use your configured environment
4. **[Start theme development](theme-development.md)** - Begin asset compilation