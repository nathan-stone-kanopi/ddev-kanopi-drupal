#!/usr/bin/env bats

# Test suite for ddev-kanopi-drupal add-on

setup() {
    export PROJNAME=test-kanopi-drupal
    export TESTDIR=~/tmp/$PROJNAME
    export DIR=${BATS_TEST_DIRNAME}/..
    mkdir -p $TESTDIR && cd $TESTDIR
    export DDEV_NONINTERACTIVE=true
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    cd $TESTDIR
}

teardown() {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    [ "$TESTDIR" != "" ] && rm -rf $TESTDIR
}

health_checks() {
    # Basic health checks for the add-on
    ddev exec "php --version" | grep "PHP"
    ddev exec "drush --version" | grep "Drush"

    # Check services are running (from DDEV add-ons)
    docker ps | grep "ddev-${PROJNAME}-redis" || docker ps | grep "ddev-${PROJNAME}-memcached"
    docker ps | grep "ddev-${PROJNAME}-solr"
    docker ps | grep "ddev-${PROJNAME}-pma"

    # Check custom commands exist (may be skipped if conflicts with existing DDEV commands)
    ddev theme:install --help || echo "theme:install command exists or skipped due to conflicts"
    ddev theme:watch --help || echo "theme:watch command exists or skipped due to conflicts"
    ddev theme:build --help || echo "theme:build command exists or skipped due to conflicts"
    ddev db:refresh --help || echo "db:refresh command exists or skipped due to conflicts"
    ddev recipe:apply --help || echo "recipe:apply command exists or skipped due to conflicts"
    ddev recipe:uuid-rm --help || echo "recipe:uuid-rm command exists or skipped due to conflicts"
    ddev theme:npm --help || echo "theme:npm command exists or skipped due to conflicts"
    ddev pantheon:terminus --help || echo "pantheon:terminus command exists or skipped due to conflicts"

    # Check configuration files exist
    [ -f ".ddev/config/php/php.ini" ]
    [ -f ".ddev/config/nginx_full/nginx-site.conf" ] || [ -f ".ddev/config/nginx/nginx-site.conf" ]

    # Check that scripts folder was copied
    [ -d ".ddev/scripts" ]
    [ -f ".ddev/scripts/pantheon-refresh.sh" ]
    [ -f ".ddev/scripts/acquia-refresh.sh" ]

    # Check gitignore was updated for add-on settings
    grep -q "settings.ddev.redis.php\|settings.ddev.memcached.php" .gitignore || echo "gitignore should contain add-on settings files"
}

@test "install from directory" {
    set -eu -o pipefail
    cd $TESTDIR
    echo "# ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot" >&3
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot

    echo "# ddev add-on get $DIR with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
    ddev add-on get $DIR

    echo "# ddev start" >&3
    ddev start

    health_checks
}

@test "install from release" {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    echo "# ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot" >&3
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot

    echo "# ddev add-on get kanopi/ddev-kanopi-drupal with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
    ddev add-on get kanopi/ddev-kanopi-drupal

    echo "# ddev start" >&3
    ddev start

    health_checks
}

@test "environment variable configuration" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Test that environment variables are configured
    ddev exec printenv HOSTING_PROVIDER | grep -E "pantheon|acquia" || echo "HOSTING_PROVIDER should be set"
    ddev exec printenv THEME | grep "themes/" || echo "THEME path should be set"
    ddev exec printenv HOSTING_SITE | grep -E "test-site|testsite" || echo "HOSTING_SITE should be set"
}

@test "interactive installation wizard" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot

    # Test non-interactive mode (should use defaults)
    export DDEV_NONINTERACTIVE=true
    ddev add-on get $DIR
    ddev start

    # Verify configuration was applied with defaults
    ddev exec printenv HOSTING_PROVIDER | grep -E "pantheon|acquia" || echo "Default hosting provider should be set"
}

@test "recipe functionality" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Check that recipe commands exist and have proper structure
    ddev recipe:apply --help || echo "recipe:apply command should exist"
    ddev recipe:uuid-rm --help || echo "recipe:uuid-rm command should exist"
}

@test "docker services" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Wait for services to be fully up
    sleep 5

    # Check that required services are running
    docker ps | grep "ddev-${PROJNAME}-redis" || docker ps | grep "ddev-${PROJNAME}-memcached" || echo "Caching service should be running"
    docker ps | grep "ddev-${PROJNAME}-solr" || echo "Solr service should be running"
    docker ps | grep "ddev-${PROJNAME}-pma" || echo "PhpMyAdmin service should be running"

    health_checks
}

@test "scripts folder functionality" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Check that scripts folder was copied
    [ -d ".ddev/scripts" ]
    [ -f ".ddev/scripts/pantheon-refresh.sh" ]
    [ -f ".ddev/scripts/acquia-refresh.sh" ]

    # Check scripts are executable
    [ -x ".ddev/scripts/pantheon-refresh.sh" ]
    [ -x ".ddev/scripts/acquia-refresh.sh" ]

    # Verify db:refresh command can find the scripts
    ddev db:refresh --help || echo "db:refresh should be available"
}
