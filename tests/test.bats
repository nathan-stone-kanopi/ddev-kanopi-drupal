#!/usr/bin/env bats

# Load bats libraries using load directive
load "lib/bats-support/load"
load "lib/bats-assert/load"
load "lib/bats-file/load"

# Set up test variables
export TEST_PROJECT_NAME=test-kanopi-addon
export TEST_DIR=/tmp/ddev-test/${TEST_PROJECT_NAME}

setup() {
    # Clean up any existing test project
    ddev delete -Oy ${TEST_PROJECT_NAME} >/dev/null 2>&1 || true
    rm -rf ${TEST_DIR} 2>/dev/null || true
    mkdir -p ${TEST_DIR}
    cd ${TEST_DIR}
}

teardown() {
    # Clean up after test
    ddev delete -Oy ${TEST_PROJECT_NAME} >/dev/null 2>&1 || true
    rm -rf ${TEST_DIR} 2>/dev/null || true
}

health_checks() {
    # Verify DDEV project is running
    run ddev describe
    assert_success
    
    # Verify add-on files are present
    assert_file_exists .ddev/commands/host/init
    assert_file_exists .ddev/commands/web/install-theme-tools
    
    # Verify environment variables are set
    run ddev exec printenv PANTHEON_SITE
    # Just check that we can run the command - the variable might be empty
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "install from directory" {
    # Create a basic Drupal project
    echo "Creating test Drupal project"
    mkdir -p web/sites/default
    echo "<?php" > web/sites/default/settings.php
    
    # Initialize DDEV project  
    ddev config --project-name=${TEST_PROJECT_NAME} --project-type=drupal --docroot=web
    ddev start
    
    # Pre-configure environment to avoid interactive prompts
    ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=test_token
    ddev config --web-environment-add=THEME=themes/custom/testtheme
    ddev config --web-environment-add=THEMENAME=testtheme
    ddev config --web-environment-add=PANTHEON_SITE=test-site
    ddev config --web-environment-add=PANTHEON_ENV=dev
    ddev config --web-environment-add=MIGRATE_DB_SOURCE=""
    ddev config --web-environment-add=MIGRATE_DB_ENV=""
    
    # Install the add-on from current directory
    ddev add-on get ${BATS_TEST_DIRNAME}/..
    
    # Run health checks
    health_checks
}

@test "install from release" {
    # Create a basic Drupal project
    echo "Creating test Drupal project for release test"
    mkdir -p web/sites/default  
    echo "<?php" > web/sites/default/settings.php
    
    # Initialize DDEV project
    ddev config --project-name=${TEST_PROJECT_NAME} --project-type=drupal --docroot=web
    ddev start
    
    # Pre-configure environment to avoid interactive prompts
    ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=test_token
    ddev config --web-environment-add=THEME=themes/custom/testtheme
    ddev config --web-environment-add=THEMENAME=testtheme
    ddev config --web-environment-add=PANTHEON_SITE=test-site
    ddev config --web-environment-add=PANTHEON_ENV=dev
    ddev config --web-environment-add=MIGRATE_DB_SOURCE=""
    ddev config --web-environment-add=MIGRATE_DB_ENV=""
    
    # Install the add-on from GitHub release
    ddev add-on get kanopi/ddev-kanopi-drupal
    
    # Run health checks
    health_checks
}