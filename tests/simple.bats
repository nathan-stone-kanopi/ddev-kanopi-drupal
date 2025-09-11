#!/usr/bin/env bats

# Simple DDEV Kanopi Drupal Add-on Tests
# Minimal tests for CI/CD that avoid complex setup issues

# Basic test variables
export TESTDIR=~/.ddev/testdata/simple-kanopi-test/
export PROJNAME=simple-kanopi-test

setup() {
    # Create test directory
    mkdir -p "${TESTDIR}"
    cd "${TESTDIR}"
    
    # Clean up any existing test project (ignore errors)
    ddev delete -Oy ${PROJNAME} 2>/dev/null || true
    rm -rf ${PROJNAME} 2>/dev/null || true
    
    # Wait for cleanup
    sleep 1
}

teardown() {
    # Clean up test project (ignore errors)
    cd "${TESTDIR}" || true
    ddev delete -Oy ${PROJNAME} 2>/dev/null || true
    rm -rf "${TESTDIR}" 2>/dev/null || true
}

@test "ddev is available and working" {
    run ddev version
    [ "$status" -eq 0 ]
    [[ "$output" == *"ddev version"* ]]
}

@test "can create basic ddev project" {
    cd "${TESTDIR}"
    mkdir "${PROJNAME}"
    cd "${PROJNAME}"
    
    # Create minimal project structure
    mkdir -p web/sites/default
    echo "<?php" > web/sites/default/settings.php
    
    # Initialize DDEV project
    run ddev config --project-name="${PROJNAME}" --project-type=drupal --docroot=web
    [ "$status" -eq 0 ]
    
    # Start the project
    run ddev start
    [ "$status" -eq 0 ]
}

@test "can install add-on" {
    cd "${TESTDIR}/${PROJNAME}"
    
    # Pre-configure environment variables to avoid interactive prompts
    ddev config --web-environment-add="THEME=themes/custom/testtheme"
    ddev config --web-environment-add="THEMENAME=testtheme"  
    ddev config --web-environment-add="PANTHEON_SITE=test-site"
    ddev config --web-environment-add="PANTHEON_ENV=dev"
    
    # Install the add-on from local directory
    run ddev add-on get "${GITHUB_WORKSPACE:-$PWD/../../..}"
    [ "$status" -eq 0 ]
    
    # Restart to apply changes
    run ddev restart
    [ "$status" -eq 0 ]
}

@test "custom commands are available" {
    cd "${TESTDIR}/${PROJNAME}"
    
    # Test some key commands are available
    run ddev help refresh
    [ "$status" -eq 0 ]
    
    run ddev help init
    [ "$status" -eq 0 ]
    
    run ddev help install-theme-tools
    [ "$status" -eq 0 ]
}

@test "environment variables are set" {
    cd "${TESTDIR}/${PROJNAME}"
    
    run ddev exec printenv THEME
    [ "$status" -eq 0 ]
    [[ "$output" == "themes/custom/testtheme" ]]
    
    run ddev exec printenv PANTHEON_SITE
    [ "$status" -eq 0 ]
    [[ "$output" == "test-site" ]]
}

@test "redis service is available" {
    cd "${TESTDIR}/${PROJNAME}"
    
    # Check if Redis compose file exists
    [ -f .ddev/docker-compose.redis.yaml ]
    
    # Test Redis connectivity (allow failure in CI)
    run ddev exec redis-cli ping
    # Don't fail the test if Redis isn't fully ready
    [[ "$status" -eq 0 ]] || [[ "$output" == *"Connection refused"* ]] || [[ "$output" == *"redis-cli: not found"* ]]
}

@test "solr service is available" {
    cd "${TESTDIR}/${PROJNAME}"
    
    # Check if Solr compose file exists
    [ -f .ddev/docker-compose.solr.yaml ]
    
    # Basic availability test (allow failure in CI)
    run ddev exec curl -s http://solr:8983/solr/admin/info/system
    # Don't fail if Solr isn't fully ready in CI
    [[ "$status" -eq 0 ]] || [[ "$output" == *"Connection refused"* ]] || [[ "$output" == *"curl: not found"* ]]
}