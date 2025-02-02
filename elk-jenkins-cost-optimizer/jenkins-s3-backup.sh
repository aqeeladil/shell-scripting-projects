#!/bin/bash

# Script: jenkins-s3-backup.sh
# Description: Automatically backs up Jenkins job logs to S3 for cost optimization
# Version: 1.0
# Author: Aqeel
# Usage: ./jenkins-s3-backup.sh [-h] [-d backup_dir] [-b bucket_name] [-r retention_days] [-c]

set -euo pipefail
IFS=$'\n\t'

# Default Configuration
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="jenkins-logs-backup"
TODAY=$(date +%Y-%m-%d)
RETENTION_DAYS=30
COMPRESS=false
LOG_FILE="/var/log/jenkins-s3-backup.log"
ERROR_COUNT=0
UPLOAD_COUNT=0

# Function to display usage
usage() {
    cat << EOF
Usage: $(basename "$0") [-h] [-d backup_dir] [-b bucket_name] [-r retention_days] [-c]

Options:
    -h              Show this help message
    -d backup_dir   Jenkins home directory (default: /var/lib/jenkins)
    -b bucket_name  S3 bucket name (default: jenkins-logs-backup)
    -r days         Retention period in days (default: 30)
    -c             Enable compression of logs before upload
EOF
    exit 1
}

# Function for logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        missing_deps+=("aws-cli")
    fi
    
    # Check gzip if compression is enabled
    if [[ "$COMPRESS" == true ]] && ! command -v gzip &> /dev/null; then
        missing_deps+=("gzip")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR" "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Function to validate S3 bucket access
validate_s3_bucket() {
    if ! aws s3 ls "s3://${S3_BUCKET}" &> /dev/null; then
        log "ERROR" "Cannot access S3 bucket: ${S3_BUCKET}"
        exit 1
    fi
}

# Function to upload file with multipart if needed
upload_to_s3() {
    local source="$1"
    local destination="$2"
    local temp_file=""
    
    # Compress if enabled
    if [[ "$COMPRESS" == true ]]; then
        temp_file="${source}.gz"
        gzip -c "$source" > "$temp_file"
        source="$temp_file"
        destination="${destination}.gz"
    fi
    
    # Try regular upload first
    if aws s3 cp "$source" "s3://${S3_BUCKET}/${destination}" --quiet; then
        ((UPLOAD_COUNT++))
        log "INFO" "Successfully uploaded: ${destination}"
    else
        log "WARN" "Regular upload failed for $source, attempting multipart upload..."
        if aws s3 cp "$source" "s3://${S3_BUCKET}/${destination}" \
            --expected-size "$(stat -f%z "$source")" --quiet; then
            ((UPLOAD_COUNT++))
            log "INFO" "Multipart upload successful: ${destination}"
        else
            ((ERROR_COUNT++))
            log "ERROR" "Failed to upload: ${destination}"
        fi
    fi
    
    # Clean up temp file if it exists
    [[ -n "$temp_file" ]] && rm -f "$temp_file"
}

# Function to clean up old backups
cleanup_old_backups() {
    local cutoff_date=$(date -v-${RETENTION_DAYS}d +%Y-%m-%d)
    log "INFO" "Cleaning up backups older than ${cutoff_date}"
    
    aws s3 ls "s3://${S3_BUCKET}" --recursive | while read -r line; do
        local file_date=$(echo "$line" | awk '{print $1}')
        if [[ "$file_date" < "$cutoff_date" ]]; then
            local file_path=$(echo "$line" | awk '{print $4}')
            if aws s3 rm "s3://${S3_BUCKET}/${file_path}" --quiet; then
                log "INFO" "Removed old backup: ${file_path}"
            else
                log "ERROR" "Failed to remove old backup: ${file_path}"
            fi
        fi
    done
}

# Parse command line arguments
while getopts ":hd:b:r:c" opt; do
    case ${opt} in
        h)
            usage
            ;;
        d)
            JENKINS_HOME=$OPTARG
            ;;
        b)
            S3_BUCKET=$OPTARG
            ;;
        r)
            RETENTION_DAYS=$OPTARG
            ;;
        c)
            COMPRESS=true
            ;;
        \?)
            log "ERROR" "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done

# Main execution
main() {
    log "INFO" "Starting Jenkins log backup to S3"
    
    # Validate inputs and requirements
    check_prerequisites
    validate_s3_bucket
    
    # Check if Jenkins home exists
    if [[ ! -d "$JENKINS_HOME" ]]; then
        log "ERROR" "Jenkins home directory does not exist: $JENKINS_HOME"
        exit 1
    }
    
    # Loop through all Jenkins jobs
    while IFS= read -r -d '' job_dir; do
        job_name=$(basename "$job_dir")
        s3_job_path="${job_name}/$(date +%Y/%m/%d)"
        
        # Loop through builds in each job
        while IFS= read -r -d '' build_dir; do
            log_file="${build_dir}/log"
            if [[ -f "$log_file" ]]; then
                file_date=$(date -r "$log_file" +%Y-%m-%d)
                if [[ "$file_date" = "$TODAY" ]]; then
                    build_number=$(basename "$build_dir")
                    destination="${s3_job_path}/build-${build_number}.log"
                    log "INFO" "Processing ${job_name} build ${build_number}"
                    upload_to_s3 "$log_file" "$destination"
                fi
            fi
        done < <(find "${job_dir}/builds" -maxdepth 1 -type d -print0)
    done < <(find "${JENKINS_HOME}/jobs" -maxdepth 1 -type d -print0)
    
    # Clean up old backups if retention is enabled
    if [[ $RETENTION_DAYS -gt 0 ]]; then
        cleanup_old_backups
    fi
    
    # Summary
    log "INFO" "Backup completed - Uploaded: $UPLOAD_COUNT, Errors: $ERROR_COUNT"
    
    # Exit with error if any uploads failed
    [[ $ERROR_COUNT -eq 0 ]] || exit 1
}

# Execute main function
main