#!/bin/bash

# Test helper functions for DDEV Kanopi Drupal Add-on bats tests

# Set DIR to the directory containing the add-on
# This allows tests to reference the local add-on directory
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Test data directory
export TESTDATA_DIR=${HOME}/.ddev/testdata
mkdir -p ${TESTDATA_DIR}

# Make sure we have the bats helpers available
if [ ! -d "${TESTDATA_DIR}/bats-support" ]; then
  echo "# Installing bats-support"
  git clone --depth 1 https://github.com/bats-core/bats-support "${TESTDATA_DIR}/bats-support"
fi

if [ ! -d "${TESTDATA_DIR}/bats-assert" ]; then
  echo "# Installing bats-assert"
  git clone --depth 1 https://github.com/bats-core/bats-assert "${TESTDATA_DIR}/bats-assert"
fi

# Load bats assertion and support libraries
load "${TESTDATA_DIR}/bats-support/load"
load "${TESTDATA_DIR}/bats-assert/load"

# Helper function to skip tests on unsupported platforms
skip_if_no_ddev() {
    if ! command -v ddev >/dev/null 2>&1; then
        skip "DDEV not available"
    fi
}

# Helper function to wait for containers to be ready
wait_for_ready() {
    local timeout=${1:-60}
    local count=0
    
    while [ $count -lt $timeout ]; do
        if ddev status | grep -q "OK"; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    echo "Timeout waiting for containers to be ready"
    return 1
}

# Helper function to clean up test projects
cleanup_test_project() {
    local project_name=${1:-test-kanopi-drupal-addon}
    
    # Stop and remove the project
    ddev stop --unlist "$project_name" 2>/dev/null || true
    ddev delete -Oy "$project_name" 2>/dev/null || true
}

# Helper function to check if a service is running
service_ready() {
    local service=$1
    local timeout=${2:-30}
    local count=0
    
    while [ $count -lt $timeout ]; do
        case $service in
            "redis")
                if ddev exec redis-cli ping 2>/dev/null | grep -q "PONG"; then
                    return 0
                fi
                ;;
            "solr")
                if ddev exec curl -s http://solr:8983/solr/admin/info/system 2>/dev/null | grep -q "solr-spec-version"; then
                    return 0
                fi
                ;;
            "web")
                if ddev exec true 2>/dev/null; then
                    return 0
                fi
                ;;
        esac
        sleep 1
        ((count++))
    done
    
    return 1
}

# Helper function to verify file exists and has expected content
assert_file_contains() {
    local file="$1"
    local expected_content="$2"
    
    [ -f "$file" ] || {
        echo "File $file does not exist"
        return 1
    }
    
    grep -q "$expected_content" "$file" || {
        echo "File $file does not contain expected content: $expected_content"
        echo "File contents:"
        cat "$file"
        return 1
    }
}

# Helper function to check environment variables in DDEV
assert_ddev_env_var() {
    local var_name="$1"
    local expected_value="$2"
    
    local actual_value
    actual_value=$(ddev exec printenv "$var_name" 2>/dev/null)
    
    [ "$actual_value" = "$expected_value" ] || {
        echo "Environment variable $var_name: expected '$expected_value', got '$actual_value'"
        return 1
    }
}

# Helper to create a minimal Drupal project structure for testing
create_minimal_drupal() {
    local docroot=${1:-web}
    
    mkdir -p "$docroot/sites/default"
    
    # Create minimal Drupal files
    cat > "$docroot/sites/default/settings.php" << 'EOF'
<?php
// Minimal settings.php for testing
$databases = [];
$settings['hash_salt'] = 'test-hash-salt';
EOF

    # Create minimal index.php
    cat > "$docroot/index.php" << 'EOF'
<?php
// Minimal Drupal bootstrap for testing
echo "Drupal test";
EOF

    # Create composer.json to identify this as a Drupal project
    cat > composer.json << 'EOF'
{
    "name": "test/drupal-project",
    "description": "Test Drupal project",
    "type": "project",
    "require": {
        "drupal/core": "^10.0"
    },
    "extra": {
        "installer-paths": {
            "web/core": ["type:drupal-core"],
            "web/modules/contrib/{$name}": ["type:drupal-module"],
            "web/themes/contrib/{$name}": ["type:drupal-theme"]
        }
    }
}
EOF
}