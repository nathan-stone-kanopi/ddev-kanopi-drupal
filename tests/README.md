# Testing the DDEV Kanopi Drupal Add-on

This directory contains bats tests for standardized testing of the DDEV Kanopi Drupal Add-on. The project uses the official DDEV add-on testing framework combined with comprehensive integration testing.

## Test Files

- `test.bats` - Main bats test suite with installation, configuration, and functionality tests
- `test_helper.bash` - Helper functions and setup for bats tests
- `README.md` - This documentation

## Running the Tests

### Prerequisites

1. **DDEV installed and working**
   ```bash
   ddev version
   ```

2. **Bats testing framework**
   ```bash
   # macOS
   brew install bats-core
   
   # Linux
   sudo apt-get install bats
   
   # Or install from source: https://bats-core.readthedocs.io/en/stable/installation.html
   ```

3. **Terminus machine token configured**
   ```bash
   # Required for Pantheon integration testing
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ```

### Run Tests

```bash
# Run all bats tests
bats tests/test.bats

# Run specific test
bats tests/test.bats -f "install from directory"

# Verbose output
bats tests/test.bats --verbose-run

# Tap output for CI
bats tests/test.bats --formatter tap
```

## Test Coverage

### Installation Tests
- ✅ Install from local directory
- ✅ Install from GitHub release
- ✅ Environment variable configuration
- ✅ pantheon.yml version detection and application

### Functionality Tests  
- ✅ All 17 custom commands availability
- ✅ Command help text and descriptions
- ✅ Environment variable propagation to containers
- ✅ Redis and Solr service integration

### Cleanup Tests
- ✅ Add-on removal process
- ✅ File and service cleanup
- ✅ Command removal verification

## Testing Strategy

| Test Type | Method | Purpose | When to Use |
|-----------|--------|---------|-------------|
| **Official DDEV Testing** | `ddev/github-action-add-on-test@v2` | Standard add-on validation | CI/CD, Pull requests |
| **Bats Tests** | `tests/test.bats` | Component/functionality testing | Local development, debugging |
| **Integration Tests** | `../test-install.sh` | End-to-end workflow testing | Release validation, troubleshooting |

### Official DDEV Testing (Primary)
- ✅ **Standardized** - Uses official DDEV testing framework
- ✅ **Reliable** - Proven patterns from DDEV team
- ✅ **Fast** - Optimized for CI/CD environments
- ✅ **Matrix testing** - Tests against stable and HEAD DDEV versions
- ✅ **Debug support** - Built-in debugging capabilities

### Bats Tests (Development)
- ✅ **Local testing** - Run specific functionality tests
- ✅ **Component testing** - Test individual features
- ✅ **Development debugging** - Quick validation during development

### Integration Tests (Comprehensive)
- ✅ **Full workflow** - Complete installation and configuration testing
- ✅ **Real Drupal** - Uses actual Drupal from git.drupalcode.org
- ✅ **Interactive testing** - Validates user experience with automated responses
- ✅ **Environment preservation** - Keeps test environment for debugging

## Customizing Tests

### Adding New Tests

```bash
@test "my new functionality test" {
    set -eu -o pipefail
    cd "${TESTDIR}/${PROJNAME}"
    
    # Your test logic here
    run ddev your-custom-command
    assert_success
    assert_output --partial "expected output"
}
```

### Testing Custom Commands

```bash
@test "custom command functionality" {
    # Test command exists
    run ddev help your-command
    assert_success
    
    # Test command execution
    run ddev your-command --test-flag
    assert_success
    assert_output "expected result"
}
```

### Environment Variable Testing

```bash
@test "custom environment variables" {
    # Test variable is set
    run ddev exec printenv YOUR_CUSTOM_VAR
    assert_success
    assert_output "expected_value"
    
    # Test variable in config
    assert_file_contains ".ddev/config.yaml" "YOUR_CUSTOM_VAR=expected_value"
}
```

## Troubleshooting Tests

### Common Issues

1. **Tests hang during installation**
   ```bash
   # Check if DDEV is responding
   ddev list
   
   # Clean up hanging tests
   ddev delete -Oy test-kanopi-drupal-addon
   ```

2. **Permission errors**
   ```bash
   # Ensure test directory is writable
   chmod -R 755 ~/.ddev/testdata/
   ```

3. **Docker/container issues**
   ```bash
   # Reset Docker
   ddev poweroff
   docker system prune -f
   ```

4. **Bats assertions failing**
   ```bash
   # Run with verbose output
   bats tests/test.bats --verbose-run
   
   # Check specific test
   bats tests/test.bats -f "failing test name"
   ```

### Debugging Test Failures

1. **Inspect preserved test environment**
   ```bash
   cd ~/.ddev/testdata/kanopi-drupal-addon/test-kanopi-drupal-addon
   ddev describe
   ddev logs
   ```

2. **Check DDEV configuration**
   ```bash
   ddev config
   cat .ddev/config.yaml
   ```

3. **Verify add-on installation**
   ```bash
   ddev add-on list --installed
   ls -la .ddev/commands/
   ```

## GitHub Actions Integration

The tests are integrated with GitHub Actions in `../.github/workflows/test.yml`:

- Runs on push/PR to main branch
- Tests multiple DDEV versions
- Multi-platform testing (Linux/macOS)  
- Uploads test artifacts on failure
- Combines both bats and integration tests

See the workflow file for detailed CI/CD configuration.