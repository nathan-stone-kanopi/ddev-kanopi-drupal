# Command Reference

The DDEV Kanopi Drupal Add-on provides 27 custom commands organized into Host Commands (executed on your local machine) and Web Commands (executed inside the DDEV container).

## Host Commands (13)

Host commands run on your local machine outside of DDEV containers and can interact with your local filesystem and external services.

### Project Management

| Command | Description | Example |
|---------|-------------|---------|
| `ddev project-init` | Complete project initialization with dependencies, Lefthook, NVM, and database refresh | `ddev project-init` |
| `ddev project-configure` | Interactive configuration wizard for project setup | `ddev project-configure` |
| `ddev project-auth` | Authorize SSH keys for hosting providers | `ddev project-auth` |
| `ddev project-lefthook` | Install and initialize Lefthook git hooks | `ddev project-lefthook` |
| `ddev project-nvm` | Install NVM and Node.js for theme development | `ddev project-nvm` |

### Database Management

| Command | Description | Example |
|---------|-------------|---------|
| `ddev db-rebuild` | Run composer install followed by database refresh | `ddev db-rebuild` |

### Testing & Development

| Command | Description | Example |
|---------|-------------|---------|
| `ddev cypress-install` | Install Cypress E2E testing dependencies | `ddev cypress-install` |
| `ddev cypress-run <command>` | Run Cypress commands with environment support | `ddev cypress-run open` |
| `ddev cypress-users` | Create default admin user for Cypress testing | `ddev cypress-users` |

### Hosting Provider Integration

| Command | Description | Example |
|---------|-------------|---------|
| `ddev pantheon-terminus <command>` | Run Terminus commands for Pantheon integration | `ddev pantheon-terminus site:list` |
| `ddev pantheon-testenv <name> [profile]` | Create isolated testing environment with optional install profile | `ddev pantheon-testenv my-test minimal` |

### Utilities

| Command | Description | Example |
|---------|-------------|---------|
| `ddev drupal-uli` | Generate one-time login link for Drupal | `ddev drupal-uli` |
| `ddev phpmyadmin` | Launch PhpMyAdmin database interface | `ddev phpmyadmin` |

## Web Commands (14)

Web commands run inside the DDEV web container and have access to the full Drupal environment, database, and installed tools.

### Database Operations

| Command | Description | Example |
|---------|-------------|---------|
| `ddev db-refresh [env] [-f]` | Smart database refresh from hosting provider with backup age detection | `ddev db-refresh live -f` |
| `ddev db-prep-migrate` | Create secondary database for migrations | `ddev db-prep-migrate` |
| `ddev pantheon-tickle` | Keep Pantheon environment awake during long operations | `ddev pantheon-tickle` |

### Theme Development

| Command | Description | Example |
|---------|-------------|---------|
| `ddev theme-install` | Set up Node.js, NPM, and build tools using .nvmrc | `ddev theme-install` |
| `ddev theme-build` | Build production assets for the theme | `ddev theme-build` |
| `ddev theme-watch` | Start theme development with file watching | `ddev theme-watch` |
| `ddev theme-npm <command>` | Run NPM commands in theme directory specified by THEME env var | `ddev theme-npm run build` |
| `ddev theme-npx <command>` | Run NPX commands in theme directory | `ddev theme-npx webpack --watch` |

### Recipe Development

| Command | Description | Example |
|---------|-------------|---------|
| `ddev recipe-apply <path>` | Apply Drupal recipe with automatic cache clearing | `ddev recipe-apply ../recipes/my-recipe` |
| `ddev recipe-unpack [recipe]` | Unpack a recipe package or all recipes | `ddev recipe-unpack drupal/example_recipe` |
| `ddev recipe-uuid-rm <path>` | Remove UUIDs from config files for recipe development | `ddev recipe-uuid-rm config/sync` |

### Performance Tools

| Command | Description | Example |
|---------|-------------|---------|
| `ddev critical-install` | Install Critical CSS generation tools | `ddev critical-install` |
| `ddev critical-run` | Run Critical CSS generation | `ddev critical-run` |

### Site Management

| Command | Description | Example |
|---------|-------------|---------|
| `ddev drupal-open [service]` | Open the site or admin in your default browser | `ddev drupal-open` |

## Command Details

### Project Initialization Commands

#### `ddev project-init`
The master initialization command that orchestrates your entire development setup:

```bash
ddev project-init
```

**What it does:**
1. Runs `ddev project-auth` to set up SSH keys
2. Runs `ddev project-lefthook` to install git hooks
3. Runs `ddev project-nvm` to set up Node.js
4. Runs `ddev db-refresh` to get the latest database
5. Runs `ddev cypress-users` to create test users

**Use case:** Perfect for daily development startup or onboarding new team members.

#### `ddev project-configure`
Interactive configuration wizard for setting up all project variables:

```bash
ddev project-configure
```

**What it configures:**
- Hosting provider (Pantheon/Acquia)
- Theme paths and names
- Site identifiers and environments
- Migration settings (optional)

### Database Operations

#### `ddev db-refresh [env] [-f]`
Smart database refresh with automatic backup age detection:

```bash
# Refresh from default environment
ddev db-refresh

# Refresh from specific environment
ddev db-refresh live

# Force new backup creation
ddev db-refresh -f

# Refresh from multidev environment
ddev db-refresh pr-123
```

**Smart Features:**
- **12-hour threshold**: Automatically detects if backups are older than 12 hours
- **Force flag**: Use `-f` to create new backup regardless of age
- **Environment support**: Works with any hosting environment
- **Post-refresh actions**: Automatically creates test users and clears caches

#### `ddev db-prep-migrate`
Creates a secondary database for migration testing:

```bash
ddev db-prep-migrate
```

**Use case:** Essential for testing migrations without affecting your main database.

### Theme Development Workflow

#### Complete Theme Setup
```bash
# 1. Install theme development tools
ddev theme-install

# 2. Start development with file watching
ddev theme-watch

# 3. Build production assets when ready
ddev theme-build
```

#### Custom NPM Commands
```bash
# Run any NPM command in your theme directory
ddev theme-npm install
ddev theme-npm run build
ddev theme-npm run lint

# Run NPX commands
ddev theme-npx webpack --analyze
ddev theme-npx stylelint "**/*.css"
```

### Recipe Development

#### Recipe Workflow
```bash
# 1. Apply a recipe
ddev recipe-apply ../recipes/my-recipe

# 2. Unpack packaged recipes for development
ddev recipe-unpack drupal/example_recipe

# 3. Clean UUIDs from config for recipe development
ddev recipe-uuid-rm config/sync

# 4. Export configuration after changes
ddev drush config:export
```

### Testing Commands

#### Cypress E2E Testing
```bash
# 1. Install Cypress (one time setup)
ddev cypress-install

# 2. Create test users
ddev cypress-users

# 3. Open Cypress UI
ddev cypress-run open

# 4. Run tests headlessly
ddev cypress-run run
```

### Performance Optimization

#### Critical CSS Generation
```bash
# 1. Install Critical CSS tools
ddev critical-install

# 2. Generate critical CSS
ddev critical-run
```

**Use case:** Improves page load performance by inlining critical CSS.

## Platform-Specific Commands

### Pantheon Commands

#### `ddev pantheon-terminus <command>`
Direct access to Terminus CLI:

```bash
# List all sites
ddev pantheon-terminus site:list

# Get site information
ddev pantheon-terminus site:info my-site

# Create multidev environment
ddev pantheon-terminus multidev:create my-site.live my-feature

# Deploy to test environment
ddev pantheon-terminus env:deploy my-site.test
```

#### `ddev pantheon-testenv <name> [profile]`
Create isolated testing environments:

```bash
# Create test environment with standard profile
ddev pantheon-testenv my-test

# Create with minimal profile
ddev pantheon-testenv my-test minimal

# Create with custom install profile
ddev pantheon-testenv my-test my_custom_profile
```

#### `ddev pantheon-tickle`
Keep environments awake during long operations:

```bash
# Run before long migrations or imports
ddev pantheon-tickle &
# Your long-running command here
ddev drush migrate:import --all
```

## Command Aliases and Shortcuts

Many commands support aliases for faster typing:

| Full Command | Aliases | Description |
|--------------|---------|-------------|
| `ddev project-configure` | `prc`, `configure` | Configuration wizard |
| `ddev db-refresh` | `refresh` | Database refresh |
| `ddev db-rebuild` | `rebuild`, `dbreb` | Database rebuild |
| `ddev theme-build` | `thb`, `production` | Theme build |
| `ddev theme-watch` | `thw`, `development` | Theme watch |
| `ddev theme-install` | `thi` | Theme install |
| `ddev recipe-apply` | `ra`, `recipe` | Apply recipe |
| `ddev recipe-unpack` | `ru` | Unpack recipe |
| `ddev cypress-install` | `cyi` | Cypress install |
| `ddev cypress-run` | `cyr`, `cy` | Cypress run |
| `ddev cypress-users` | `cyu` | Create users |

## Environment Variables

Commands use these key environment variables (configured via `ddev project-configure`):

| Variable | Description | Example |
|----------|-------------|---------|
| `HOSTING_PROVIDER` | Platform identifier | `pantheon`, `acquia` |
| `THEME` | Path to custom theme | `themes/custom/mytheme` |
| `THEMENAME` | Theme name for tools | `mytheme` |
| `HOSTING_SITE` | Site identifier | `my-site` (Pantheon), `app-uuid` (Acquia) |
| `HOSTING_ENV` | Default environment | `dev`, `test`, `live` |

## Getting Help

Get help for any command:

```bash
# Get command help
ddev <command> --help

# Example
ddev db-refresh --help
ddev theme-install --help
```

## Next Steps

For detailed information on database operations, theme development, recipe workflow, and testing, refer to the individual command documentation and help text using `ddev [command] --help`.