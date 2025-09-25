# Hosting Providers

The DDEV Kanopi Drupal Add-on provides comprehensive support for multiple hosting providers with platform-specific optimizations and integrations.

## Supported Providers

| Provider | Status | Configuration | Webserver | Database | Caching |
|----------|--------|---------------|-----------|----------|---------|
| **[Pantheon](providers/pantheon.md)** | ✅ Full Support | Terminus API | Nginx + Proxy | MariaDB 10.6 | Redis |
| **[Acquia](providers/acquia.md)** | ✅ Full Support | Acquia CLI | Apache-FPM | MySQL 5.7 | Memcached |

## Provider Selection

Choose your hosting provider during installation or reconfigure anytime:

```bash
# Interactive configuration
ddev project-configure

# Manual configuration
ddev config --web-environment-add HOSTING_PROVIDER=pantheon
# or
ddev config --web-environment-add HOSTING_PROVIDER=acquia
```

## Platform Comparison

### Pantheon
- **Best for**: High-traffic sites, integrated CI/CD, automatic updates
- **Strengths**: Excellent performance, built-in CDN, robust backup system
- **DDEV Integration**: Automatic nginx proxy, Terminus CLI, smart backup detection

### Acquia
- **Best for**: Enterprise sites, complex architectures, compliance requirements
- **Strengths**: Advanced security, multi-region deployments, comprehensive tooling
- **DDEV Integration**: Apache-FPM compatibility, Acquia CLI, file proxy system

## Common Features

All supported hosting providers include:

### Smart Database Refresh
- **12-hour backup detection**: Automatically checks backup age
- **Force refresh**: Use `-f` flag to create new backups
- **Environment support**: Pull from any environment (dev, test, live, multidev)
- **Post-refresh actions**: Automatic user creation and cache clearing

### Asset Proxy
- **Missing file handling**: Automatically proxy missing assets from hosting environment
- **Development efficiency**: No need to download all media files locally
- **Seamless integration**: Transparent to your development workflow

### API Integration
- **Native CLI tools**: Direct access to hosting provider APIs
- **Automated workflows**: Streamlined deployment and backup processes
- **Environment management**: Create and manage environments programmatically

## Provider-Specific Guides

- **[Pantheon Setup Guide](providers/pantheon.md)** - Complete Pantheon configuration
- **[Acquia Setup Guide](providers/acquia.md)** - Complete Acquia configuration

## Multi-Provider Workflows

### Migration Between Providers

The add-on supports migrating between hosting providers:

```bash
# Configure source for migration
ddev config --web-environment-add MIGRATE_DB_SOURCE=old-site
ddev config --web-environment-add MIGRATE_DB_ENV=live

# Set up secondary database for migration
ddev db-prep-migrate

# Your migration process here...
```

### Development with Multiple Providers

You can work with multiple providers in different projects:

```bash
# Project A (Pantheon)
cd project-a
ddev config --web-environment-add HOSTING_PROVIDER=pantheon

# Project B (Acquia)
cd project-b
ddev config --web-environment-add HOSTING_PROVIDER=acquia
```

Global credentials are shared across projects for convenience.