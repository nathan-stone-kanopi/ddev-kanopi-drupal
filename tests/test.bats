#!/usr/bin/env bats

# DDEV Kanopi Drupal Add-on Tests
# Based on DDEV add-on template but adapted for Kanopi's complex interactive installation

# Load test helpers
load test_helper.bash

# Temporary directory for test project
export TESTDIR=~/.ddev/testdata/kanopi-drupal-addon/
export PROJNAME=test-kanopi-drupal-addon
export DDEV_NON_INTERACTIVE=true

# Test values for non-interactive installation
export TEST_THEME="themes/custom/testtheme"
export TEST_THEMENAME="testtheme"
export TEST_PANTHEON_SITE="test-site-123"
export TEST_PANTHEON_ENV="dev"
export TEST_MIGRATE_SOURCE="migration-source"
export TEST_MIGRATE_ENV="live"

setup() {
    set -eu -o pipefail
    cd "${TESTDIR}"
    ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
    [[ ! -d "${PROJNAME}" ]] || rm -rf ${PROJNAME}
}

health_checks() {
    # Basic health checks for the add-on
    
    # Check that DDEV is running
    run ddev describe
    assert_success
    
    # Check that custom commands are available
    run ddev help refresh
    assert_success
    
    # Check that environment variables are set
    run bash -c "ddev exec printenv | grep THEME"
    assert_success
    
    # Check that Pantheon site variable is set  
    run bash -c "ddev exec printenv | grep PANTHEON_SITE"
    assert_success
    
    # Check that Redis is installed
    [ -f .ddev/docker-compose.redis.yaml ]
    
    # Check that Solr is installed
    [ -f .ddev/docker-compose.solr.yaml ]
    
    # Check that custom commands exist
    [ -f .ddev/commands/host/init ]
    [ -f .ddev/commands/host/refresh ]
    [ -f .ddev/commands/web/install-theme-tools ]
    
    # Check that add-on is listed as installed
    run ddev add-on list --installed
    assert_success
    assert_output --partial "kanopi"
}

teardown() {
    set -eu -o pipefail
    cd "${TESTDIR}" || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
    ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
}

@test "install from directory" {
    set -eu -o pipefail
    cd "${TESTDIR}"
    
    # Create a basic Drupal project structure
    mkdir "${PROJNAME}"
    cd "${PROJNAME}"
    
    # Create minimal Drupal structure
    mkdir -p web/sites/default
    echo "<?php" > web/sites/default/settings.php
    
    # Create pantheon.yml with test versions
    cat > pantheon.yml << EOF
api_version: 1
web_docroot: web
php_version: "8.3"
database:
  version: "10.6"
object_cache:
  version: "7"
EOF

    # Initialize DDEV project
    ddev config --project-type=drupal --docroot=web --project-name=${PROJNAME}
    ddev start
    
    # Set up test environment variables to simulate interactive responses
    ddev config --web-environment-add "THEME=${TEST_THEME}"
    ddev config --web-environment-add "THEMENAME=${TEST_THEMENAME}"
    ddev config --web-environment-add "PANTHEON_SITE=${TEST_PANTHEON_SITE}"
    ddev config --web-environment-add "PANTHEON_ENV=${TEST_PANTHEON_ENV}"
    ddev config --web-environment-add "MIGRATE_DB_SOURCE=${TEST_MIGRATE_SOURCE}"
    ddev config --web-environment-add "MIGRATE_DB_ENV=${TEST_MIGRATE_ENV}"
    
    # Install the add-on from local directory
    ddev add-on get "${DIR}"
    
    # Restart to apply changes
    ddev restart
    
    # Run health checks
    health_checks
}

@test "install from release" {
    set -eu -o pipefail
    cd "${TESTDIR}"
    
    # Create a basic Drupal project structure
    mkdir "${PROJNAME}"
    cd "${PROJNAME}"
    
    # Create minimal Drupal structure
    mkdir -p web/sites/default
    echo "<?php" > web/sites/default/settings.php
    
    # Create pantheon.yml with test versions
    cat > pantheon.yml << EOF
api_version: 1
web_docroot: web
php_version: "8.3"
database:
  version: "10.6"
object_cache:
  version: "7"
EOF

    # Initialize DDEV project
    ddev config --project-type=drupal --docroot=web --project-name=${PROJNAME}
    ddev start
    
    # Set up test environment variables to simulate interactive responses
    ddev config --web-environment-add "THEME=${TEST_THEME}"
    ddev config --web-environment-add "THEMENAME=${TEST_THEMENAME}"
    ddev config --web-environment-add "PANTHEON_SITE=${TEST_PANTHEON_SITE}"
    ddev config --web-environment-add "PANTHEON_ENV=${TEST_PANTHEON_ENV}"
    ddev config --web-environment-add "MIGRATE_DB_SOURCE=${TEST_MIGRATE_SOURCE}"
    ddev config --web-environment-add "MIGRATE_DB_ENV=${TEST_MIGRATE_ENV}"
    
    # Install the add-on from GitHub release
    ddev add-on get kanopi/ddev-kanopi-drupal
    
    # Restart to apply changes
    ddev restart
    
    # Run health checks
    health_checks
}

@test "command functionality tests" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Test help command for custom commands
    run ddev help refresh
    assert_success
    assert_output --partial "Downloads the database from the provider"
    
    run ddev help init
    assert_success
    assert_output --partial "Complete project initialization"
    
    run ddev help install-theme-tools
    assert_success
    assert_output --partial "Install and set up theme development tools"
    
    # Test that npm command wrapper exists
    run ddev help npm
    assert_success
    
    # Test that recipe-apply command exists
    run ddev help recipe-apply
    assert_success
    assert_output --partial "Apply Drupal recipe"
    
    # Test Cypress commands
    run ddev help cypress-users
    assert_success
    assert_output --partial "Create default admin user"
}

@test "environment variable configuration" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Check that all required environment variables are set
    run ddev exec printenv THEME
    assert_success
    assert_output "${TEST_THEME}"
    
    run ddev exec printenv THEMENAME
    assert_success
    assert_output "${TEST_THEMENAME}"
    
    run ddev exec printenv PANTHEON_SITE
    assert_success
    assert_output "${TEST_PANTHEON_SITE}"
    
    run ddev exec printenv PANTHEON_ENV
    assert_success
    assert_output "${TEST_PANTHEON_ENV}"
    
    # Optional migration variables
    run ddev exec printenv MIGRATE_DB_SOURCE
    assert_success
    assert_output "${TEST_MIGRATE_SOURCE}"
    
    run ddev exec printenv MIGRATE_DB_ENV
    assert_success
    assert_output "${TEST_MIGRATE_ENV}"
}

@test "redis and solr integration" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Check Redis container is running
    run ddev exec redis-cli ping
    assert_success
    assert_output "PONG"
    
    # Check Solr container is running
    run ddev exec curl -s http://solr:8983/solr/admin/cores
    assert_success
    
    # Verify Redis compose file exists
    [ -f .ddev/docker-compose.redis.yaml ]
    
    # Verify Solr compose file exists
    [ -f .ddev/docker-compose.solr.yaml ]
}

@test "pantheon.yml version detection" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Check that PHP version from pantheon.yml was applied
    run ddev exec php -v
    assert_success
    assert_output --partial "PHP 8.3"
    
    # Check that database version was configured (MariaDB 10.6)
    run ddev exec mysql --version
    assert_success
    assert_output --partial "10.6"
}

@test "add-on removal" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Test add-on removal
    run ddev add-on remove kanopi-pantheon-drupal
    assert_success
    
    # Verify custom commands are removed
    run ddev help refresh
    assert_failure
    
    # Verify Redis and Solr are removed
    [ ! -f .ddev/docker-compose.redis.yaml ]
    [ ! -f .ddev/docker-compose.solr.yaml ]
    
    # Verify command directories are cleaned up
    [ ! -d .ddev/commands/host ]
    [ ! -d .ddev/commands/web ]
}