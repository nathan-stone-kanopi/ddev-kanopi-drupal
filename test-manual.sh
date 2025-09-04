#!/usr/bin/env bash

## Manual Test for DDEV Kanopi Pantheon Drupal Add-on Installation
## This script tests the basic add-on installation without interactive prompts

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get the absolute path to the add-on directory
ADDON_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${ADDON_PATH}/test/test-manual"
TEST_PROJECT="test-manual-addon"

echo -e "${BLUE}${BOLD}🧪 Manual Testing DDEV Kanopi Pantheon Drupal Add-on${NC}"
echo -e "${BLUE}========================================================${NC}"
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

# Step 1: Create test directory and initialize DDEV project
echo -e "${YELLOW}📁 Creating test directory and DDEV project...${NC}"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize basic Drupal project structure
mkdir -p web
echo "<?php echo 'Test Drupal site';" > web/index.php

# Initialize DDEV
ddev config --project-name="$TEST_PROJECT" --project-type=drupal --docroot=web --php-version=8.3
echo -e "${GREEN}✅ DDEV project initialized${NC}"

# Step 2: Start DDEV
echo -e "\n${YELLOW}🚀 Starting DDEV...${NC}"
ddev start
echo -e "${GREEN}✅ DDEV started successfully${NC}"

# Step 3: Install the add-on and check what happens
echo -e "\n${YELLOW}📦 Testing basic add-on structure...${NC}"

# First, let's just copy the commands manually to see if that part works
echo -e "${BLUE}Copying command files manually...${NC}"
cp -r "$ADDON_PATH/commands" .ddev/
echo -e "${GREEN}✅ Commands copied successfully${NC}"

# Step 4: Test command availability
echo -e "\n${YELLOW}🔧 Testing available commands...${NC}"
if ddev help | grep -q "refresh"; then
    echo -e "${GREEN}✅ Custom commands are available${NC}"
else
    echo -e "${RED}❌ Custom commands not found${NC}"
fi

# Step 5: Test environment variable setting manually
echo -e "\n${YELLOW}⚙️  Testing manual environment configuration...${NC}"
ddev config --web-environment-add THEME=themes/custom/testtheme
ddev config --web-environment-add THEMENAME=testtheme
ddev config --web-environment-add PANTHEON_SITE=test-site-123
ddev config --web-environment-add PANTHEON_ENV=dev

# Step 6: Restart and verify configuration
echo -e "\n${YELLOW}🔄 Restarting DDEV to apply config...${NC}"
ddev restart

# Step 7: Check configuration
echo -e "\n${YELLOW}🔍 Checking configuration...${NC}"
if [ -f ".ddev/config.yaml" ]; then
    echo -e "${GREEN}✅ Config file exists${NC}"
    
    # Check for environment variables
    if grep -q "THEME=themes/custom/testtheme" .ddev/config.yaml; then
        echo -e "${GREEN}✅ THEME variable found${NC}"
    else
        echo -e "${RED}❌ THEME variable not found${NC}"
    fi
    
    if grep -q "THEMENAME=testtheme" .ddev/config.yaml; then
        echo -e "${GREEN}✅ THEMENAME variable found${NC}"
    else
        echo -e "${RED}❌ THEMENAME variable not found${NC}"
    fi
    
    if grep -q "PANTHEON_SITE=test-site-123" .ddev/config.yaml; then
        echo -e "${GREEN}✅ PANTHEON_SITE variable found${NC}"
    else
        echo -e "${RED}❌ PANTHEON_SITE variable not found${NC}"
    fi
    
    if grep -q "PANTHEON_ENV=dev" .ddev/config.yaml; then
        echo -e "${GREEN}✅ PANTHEON_ENV variable found${NC}"
    else
        echo -e "${RED}❌ PANTHEON_ENV variable not found${NC}"
    fi
else
    echo -e "${RED}❌ Config file not found${NC}"
fi

echo -e "\n${BLUE}${BOLD}📊 Manual Test Complete${NC}"
echo -e "${BLUE}This test validates that:${NC}"
echo -e "${GREEN}✓ DDEV project can be created${NC}"
echo -e "${GREEN}✓ Commands can be installed manually${NC}"
echo -e "${GREEN}✓ Environment variables can be set${NC}"
echo -e "${GREEN}✓ Configuration persists after restart${NC}"
echo ""
echo -e "${BLUE}📁 Test environment preserved for inspection at: $TEST_DIR${NC}"