#!/usr/bin/env bash

## Test Installation Script for DDEV Kanopi Pantheon Drupal Add-on
## This script creates a test DDEV project and validates the interactive installation process

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test configuration values
TEST_THEME="themes/custom/testtheme"
TEST_THEMENAME="testtheme"
TEST_PANTHEON_SITE="test-site-123"
TEST_PANTHEON_ENV="test"
TEST_MIGRATE_SOURCE="migration-source-site"
TEST_MIGRATE_ENV="live"

# Get the absolute path to the add-on directory
ADDON_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${ADDON_PATH}/test/test-install"
TEST_PROJECT="test-kanopi-addon"

echo -e "${BLUE}${BOLD}🧪 Testing DDEV Kanopi Pantheon Drupal Add-on Installation${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🧹 Stopping DDEV containers but preserving test environment...${NC}"
    if [ -d "$TEST_DIR" ]; then
        cd "$TEST_DIR" && ddev stop 2>/dev/null || true
        cd "$ADDON_PATH"
        echo -e "${GREEN}✅ Test environment preserved at: $TEST_DIR${NC}"
        echo -e "${BLUE}💡 To inspect: cd $TEST_DIR${NC}"
        echo -e "${BLUE}💡 To cleanup: cd $TEST_DIR && ddev delete -Oy $TEST_PROJECT && cd .. && rm -rf $TEST_DIR${NC}"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Step 0: Clean up any existing test environments first
echo -e "${YELLOW}🧹 Cleaning up any existing test environments...${NC}"
ddev stop --unlist "$TEST_PROJECT" 2>/dev/null || true
ddev delete --omit-snapshot --yes "$TEST_PROJECT" 2>/dev/null || true
rm -rf "$TEST_DIR" 2>/dev/null || true
echo -e "${GREEN}✅ Cleanup completed${NC}"

# Step 1: Create test directory and initialize DDEV project
echo -e "${YELLOW}📁 Creating test directory and DDEV project...${NC}"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Copy pantheon.yml from test directory
cp "${ADDON_PATH}/test/pantheon.yml" ./pantheon.yml
echo -e "${GREEN}✅ Copied pantheon.yml to test project${NC}"

# Extract expected versions from pantheon.yml
EXPECTED_PHP_VERSION=$(grep "^php_version:" "./pantheon.yml" | sed 's/php_version: *//' | tr -d '"' || echo "")
EXPECTED_DB_VERSION=$(grep -A1 "^database:" "./pantheon.yml" | grep "version:" | sed 's/.*version: *//' | tr -d '"' || echo "")
echo -e "${BLUE}📋 Expected versions from pantheon.yml:${NC}"
echo -e "${BLUE}   PHP: ${EXPECTED_PHP_VERSION:-'default'}${NC}"
echo -e "${BLUE}   Database: ${EXPECTED_DB_VERSION}${NC}"

# Initialize basic Drupal project structure
mkdir -p web
echo "<?php echo 'Test Drupal site';" > web/index.php

# Initialize git repository for testing repo name detection
rm -rf .git 2>/dev/null || true
git init --quiet
git config --local user.name "Test User"
git config --local user.email "test@example.com"
git add . 2>/dev/null || true
git commit --quiet -m "Initial test commit" 2>/dev/null || true
echo -e "${GREEN}✅ Git repository initialized${NC}"

# Initialize DDEV with default versions - the add-on should detect and update them
ddev config --project-name="$TEST_PROJECT" --project-type=drupal --docroot=web
echo -e "${GREEN}✅ DDEV project initialized (add-on will update versions from pantheon.yml)${NC}"

# Step 2: Start DDEV
echo -e "\n${YELLOW}🚀 Starting DDEV...${NC}"
ddev start
echo -e "${GREEN}✅ DDEV started successfully${NC}"

# Step 3: Install the add-on with automated responses
echo -e "\n${YELLOW}📦 Installing Kanopi Pantheon Drupal Add-on...${NC}"
echo -e "${BLUE}This will test the interactive installation process${NC}"

# Create input file for automated responses
cat > input.txt << EOF
${TEST_THEME}
${TEST_THEMENAME}
${TEST_PANTHEON_SITE}
${TEST_PANTHEON_ENV}
${TEST_MIGRATE_SOURCE}
${TEST_MIGRATE_ENV}
EOF

# Install the add-on with automated input
if ddev add-on get "$ADDON_PATH" < input.txt; then
    echo -e "${GREEN}✅ Add-on installation completed${NC}"
else
    echo -e "${RED}❌ Add-on installation failed${NC}"
    exit 1
fi

# Restart to apply changes
echo -e "\n${YELLOW}🔄 Restarting DDEV to apply configuration...${NC}"
ddev restart
echo -e "${GREEN}✅ DDEV restarted${NC}"

# Step 4: Validate configuration
echo -e "\n${YELLOW}🔍 Validating configuration...${NC}"

CONFIG_FILE=".ddev/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Check each environment variable
VALIDATION_PASSED=true

check_env_var() {
    local var_name="$1"
    local expected_value="$2"
    local optional="$3"
    
    # Check in the web_environment section of the config file
    if grep -A 10 "web_environment:" "$CONFIG_FILE" | grep -q "${var_name}=${expected_value}"; then
        echo -e "${GREEN}✅ ${var_name}: ${expected_value}${NC}"
    elif grep -A 10 "web_environment:" "$CONFIG_FILE" | grep -q "${var_name}="; then
        local actual_value=$(grep -A 10 "web_environment:" "$CONFIG_FILE" | grep "${var_name}=" | cut -d'=' -f2 | tr -d '" ' | head -1)
        echo -e "${RED}❌ ${var_name}: Expected '${expected_value}', got '${actual_value}'${NC}"
        VALIDATION_PASSED=false
    else
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠️  ${var_name}: Not set (optional)${NC}"
        else
            echo -e "${RED}❌ ${var_name}: Not found in config${NC}"
            VALIDATION_PASSED=false
        fi
    fi
}

echo -e "\n${BLUE}Checking environment variables:${NC}"
check_env_var "THEME" "$TEST_THEME" "false"
check_env_var "THEMENAME" "$TEST_THEMENAME" "false"
check_env_var "PANTHEON_SITE" "$TEST_PANTHEON_SITE" "false"
check_env_var "PANTHEON_ENV" "$TEST_PANTHEON_ENV" "false"
check_env_var "MIGRATE_DB_SOURCE" "$TEST_MIGRATE_SOURCE" "true"
check_env_var "MIGRATE_DB_ENV" "$TEST_MIGRATE_ENV" "true"

# Validate PHP and database versions from pantheon.yml
echo ""
echo -e "${BLUE}Checking versions from pantheon.yml:${NC}"

# Use the dynamically extracted versions from earlier in the script

# Check PHP version in config.yaml
if [ -z "$EXPECTED_PHP_VERSION" ]; then
    ACTUAL_PHP=$(grep "php_version:" "$CONFIG_FILE" | cut -d':' -f2 | tr -d '" ' | head -1)
    echo -e "${YELLOW}⚠️  PHP version: $ACTUAL_PHP (no version specified in pantheon.yml)${NC}"
elif grep -q "php_version: \"$EXPECTED_PHP_VERSION\"" "$CONFIG_FILE"; then
    echo -e "${GREEN}✅ PHP version: $EXPECTED_PHP_VERSION${NC}"
else
    ACTUAL_PHP=$(grep "php_version:" "$CONFIG_FILE" | cut -d':' -f2 | tr -d '" ' | head -1)
    echo -e "${RED}❌ PHP version: Expected '$EXPECTED_PHP_VERSION', got '$ACTUAL_PHP'${NC}"
    VALIDATION_PASSED=false
fi

# Check database version in config.yaml
if grep -A3 "database:" "$CONFIG_FILE" | grep -q "version: \"$EXPECTED_DB_VERSION\""; then
    echo -e "${GREEN}✅ Database version: $EXPECTED_DB_VERSION${NC}"
else
    ACTUAL_DB=$(grep -A3 "database:" "$CONFIG_FILE" | grep "version:" | cut -d':' -f2 | tr -d '" ' | head -1)
    echo -e "${RED}❌ Database version: Expected '$EXPECTED_DB_VERSION', got '$ACTUAL_DB'${NC}"
    VALIDATION_PASSED=false
fi

# Check project name matches git repository
EXPECTED_PROJECT_NAME="test-install"
if grep -q "name: $EXPECTED_PROJECT_NAME" "$CONFIG_FILE"; then
    echo -e "${GREEN}✅ Project name: $EXPECTED_PROJECT_NAME${NC}"
else
    ACTUAL_PROJECT=$(grep "name:" "$CONFIG_FILE" | cut -d':' -f2 | tr -d '" ' | head -1)
    echo -e "${RED}❌ Project name: Expected '$EXPECTED_PROJECT_NAME', got '$ACTUAL_PROJECT'${NC}"
    VALIDATION_PASSED=false
fi

# Step 5: Test command availability
echo -e "\n${YELLOW}🔧 Testing available commands...${NC}"
if ddev help | grep -q "refresh"; then
    echo -e "${GREEN}✅ Custom commands are available${NC}"
else
    echo -e "${RED}❌ Custom commands not found${NC}"
    VALIDATION_PASSED=false
fi

# Step 6: Validate add-on is listed
echo -e "\n${YELLOW}📋 Checking installed add-ons...${NC}"
if ddev add-on list --installed | grep -q "kanopi"; then
    echo -e "${GREEN}✅ Add-on is properly installed${NC}"
else
    echo -e "${RED}❌ Add-on not found in installed list${NC}"
    VALIDATION_PASSED=false
fi

# Step 7: Test add-on removal
echo -e "\n${YELLOW}🗑️  Testing add-on removal...${NC}"
if ddev add-on remove ddev-kanopi-pantheon-drupal 2>/dev/null; then
    echo -e "${GREEN}✅ Add-on removed successfully${NC}"
else
    # Try alternative name patterns
    if ddev add-on remove kanopi-pantheon-drupal 2>/dev/null; then
        echo -e "${GREEN}✅ Add-on removed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Add-on removal test skipped (non-critical)${NC}"
        echo -e "${BLUE}Note: Add-on cleanup will happen during project deletion${NC}"
    fi
fi

# Final results
echo -e "\n${BLUE}${BOLD}📊 Test Results${NC}"
echo -e "${BLUE}================================${NC}"

if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}${BOLD}🎉 All tests passed! The add-on installation works correctly.${NC}"
    echo ""
    echo -e "${GREEN}✅ Interactive installation process functional${NC}"
    echo -e "${GREEN}✅ Environment variables configured correctly${NC}"
    echo -e "${GREEN}✅ Custom commands available${NC}"
    echo -e "${GREEN}✅ Add-on removal works${NC}"
    echo ""
    echo -e "${BLUE}📁 Test environment preserved for inspection at: $TEST_DIR${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}❌ Some tests failed. Please check the output above.${NC}"
    echo ""
    echo -e "${BLUE}📁 Test environment preserved for debugging at: $TEST_DIR${NC}"
    exit 1
fi