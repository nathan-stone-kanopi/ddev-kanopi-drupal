#!/usr/bin/env bash

## Acquia database refresh script
## Called from the main refresh command when HOSTING_PROVIDER=acquia

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Function to authenticate with Acquia CLI
authenticate_acquia() {
    echo -e "\n${yellow} Authenticating with Acquia CLI... ${NC}"
    
    # Get API credentials from environment
    ACQUIA_API_KEY=$(printenv ACQUIA_API_KEY 2>/dev/null)
    ACQUIA_API_SECRET=$(printenv ACQUIA_API_SECRET 2>/dev/null)
    
    if [ -z "${ACQUIA_API_KEY:-}" ] || [ -z "${ACQUIA_API_SECRET:-}" ]; then
        echo -e "${red}ACQUIA_API_KEY and ACQUIA_API_SECRET environment variables are not set in the web container. Please configure them in your global ddev config.${NC}"
        exit 1
    fi

    # Authenticate with acli using API credentials
    if ! acli auth:login --key="${ACQUIA_API_KEY}" --secret="${ACQUIA_API_SECRET}"; then
        echo -e "${red}Failed to authenticate with Acquia CLI. Please check your API credentials.${NC}"
        exit 1
    fi
    echo -e "${green}Successfully authenticated with Acquia CLI.${NC}"
}

# Function to refresh database from Acquia
refresh_acquia_database() {
    local ENVIRONMENT="$1"
    local FORCE_BACKUP="$2"
    
    echo -e "\n${yellow} Get database from Acquia environment: ${ENVIRONMENT}. ${NC}"
    echo -e "${green}${divider}${NC}"
    
    # Extract application name from HOSTING_SITE environment variable or fall back to DDEV project name.
    APP_NAME="${HOSTING_SITE:-$DDEV_PROJECT}"
    
    # Acquia environment format
    APP_ENV="${APP_NAME}.${ENVIRONMENT}"
    
    # Define the local database dump file path
    DB_DUMP="/tmp/acquia_backup.${APP_ENV}.sql.gz"

    echo -e "\nChecking for local database dump file..."

    # Calculate current time and 12-hour threshold.
    CURRENT_TIME=$(date +%s)
    TWELVE_HOURS_AGO=$((CURRENT_TIME - 43200))  # 12 hours = 43200 seconds

    DOWNLOAD_NEW_BACKUP=false

    # Check if force flag is set
    if [ "$FORCE_BACKUP" = true ]; then
        echo -e "${yellow}Force flag detected. Will download fresh backup regardless of local file age.${NC}"
        DOWNLOAD_NEW_BACKUP=true
    else
        # Check if local dump file exists and its age
        if [ -f "$DB_DUMP" ]; then
            # Get file modification time
            LOCAL_FILE_TIME=""

            # Try different methods to get the file modification time
            if [ -z "$LOCAL_FILE_TIME" ]; then
                # Method 1: Try stat with format specifier (GNU/Linux style)
                LOCAL_FILE_TIME=$(stat -c %Y "$DB_DUMP" 2>/dev/null)
            fi

            if [ -z "$LOCAL_FILE_TIME" ]; then
                # Method 2: Try stat with format specifier (BSD/macOS style)
                LOCAL_FILE_TIME=$(stat -f %m "$DB_DUMP" 2>/dev/null)
            fi

            if [ -z "$LOCAL_FILE_TIME" ]; then
                # Method 3: Use date command with file reference
                LOCAL_FILE_TIME=$(date -r "$DB_DUMP" +%s 2>/dev/null)
            fi

            # Ensure we got a valid timestamp (numeric value)
            if [ -n "$LOCAL_FILE_TIME" ] && echo "$LOCAL_FILE_TIME" | grep -q '^[0-9][0-9]*$'; then
                if [ "$LOCAL_FILE_TIME" -lt "$TWELVE_HOURS_AGO" ]; then
                    LOCAL_AGE_HOURS=$(( (CURRENT_TIME - LOCAL_FILE_TIME) / 3600 ))
                    echo -e "${yellow}Local dump file is ${LOCAL_AGE_HOURS} hours old (older than 12 hours).${NC}"
                    DOWNLOAD_NEW_BACKUP=true
                else
                    LOCAL_AGE_HOURS=$(( (CURRENT_TIME - LOCAL_FILE_TIME) / 3600 ))
                    echo -e "${green}Recent local dump file found (${LOCAL_AGE_HOURS} hours old). Using existing file.${NC}"
                fi
            else
                echo -e "${yellow}Could not determine local file age (got: '$LOCAL_FILE_TIME'). Will download fresh backup.${NC}"
                DOWNLOAD_NEW_BACKUP=true
            fi
        else
            echo -e "${yellow}No local dump file found.${NC}"
            DOWNLOAD_NEW_BACKUP=true
        fi
    fi

    CREATE_NEW_BACKUP=false

    if [ "$DOWNLOAD_NEW_BACKUP" = true ]; then
        echo -e "\nChecking for database backup on ${APP_ENV}..."

        # Check if there's a database backup and get its timestamp using acli
        # Note: This is a simplified version - actual acli commands may differ
        LATEST_BACKUP_INFO=$(acli api:environments:database-backup-list ${APP_ENV} 2>/dev/null | head -1)

        # Check if force flag is set or no backup exists
        if [ "$FORCE_BACKUP" = true ]; then
            echo -e "${yellow}Force flag detected. Creating new backup regardless of age.${NC}"
            CREATE_NEW_BACKUP=true
        elif [ -z "$LATEST_BACKUP_INFO" ]; then
            echo -e "${yellow}No database backup found or could not retrieve backup info.${NC}"
            CREATE_NEW_BACKUP=true
        else
            echo -e "${green}Using existing backup (age check simplified for Acquia).${NC}"
            # Note: Acquia backup age checking would need more specific acli command parsing
            # This is simplified - you may need to adjust based on actual acli output format
        fi
    fi

    if [ "$CREATE_NEW_BACKUP" = true ]; then
        echo -e "${yellow}Creating new backup for ${APP_ENV}...${NC}"
        if acli api:environments:database-backup-create ${APP_ENV}; then
            echo -e "${green}Backup created successfully.${NC}"
            # Wait a moment for the backup to be processed
            echo "Waiting for backup to complete..."
            sleep 20  # Acquia may need more time
        else
            echo -e "${red}Failed to create backup for ${APP_ENV}. Exiting.${NC}"
            exit 1
        fi
    fi

    # Download the database backup using acli
    if [ "$DOWNLOAD_NEW_BACKUP" = true ]; then
        echo -e "\nDownloading database backup from ${APP_ENV}..."
        # Note: Actual acli command may differ - this is a simplified version
        if acli api:environments:database-backup-download ${APP_ENV} --file=${DB_DUMP}; then
            echo -e "${green}Database backup downloaded successfully.${NC}"
        else
            echo -e "${red}Failed to download database backup. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "\nUsing existing local database dump file."
    fi

    echo -e "\nReset DB"
    drush sql-drop -y

    echo -e "\nImport DB"
    if [[ "$DB_DUMP" == *.gz ]]; then
        gunzip -c ${DB_DUMP} | $(drush sql:connect)
    else
        cat ${DB_DUMP} | $(drush sql:connect)
    fi
}

# Main execution
authenticate_acquia
refresh_acquia_database "$@"