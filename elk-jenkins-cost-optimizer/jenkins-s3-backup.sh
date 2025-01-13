#!/bin/bash

# Script: jenkins-s3-backup.sh
# Description: Automatically backs up Jenkins job logs to S3 for cost optimization
# Version: 1.0
# Author: Aqeel
# Usage: ./jenkins-s3-backup.sh

# Configuration
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="jenkins-logs-backup"
TODAY=$(date +%Y-%m-%d)

# Verify AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it to proceed."
    exit 1
fi

# Function to upload file with multipart if needed
upload_to_s3() {
    local source="$1"
    local destination="$2"
    
    if ! aws s3 cp "$source" "s3://${S3_BUCKET}/${destination}"; then
        echo "Regular upload failed for $source, attempting multipart upload..."
        aws s3 cp "$source" "s3://${S3_BUCKET}/${destination}" --expected-size $(stat -f%z "$source")
    fi
}

# Loop through all Jenkins jobs
for job_dir in ${JENKINS_HOME}/jobs/*; do
    if [ -d "$job_dir" ]; then
        job_name=$(basename "$job_dir")
        
        # Create S3 folder structure by job
        s3_job_path="${job_name}/$(date +%Y/%m/%d)"
        
        # Loop through builds in each job
        for build_dir in "${job_dir}/builds/"*; do
            if [ -d "$build_dir" ]; then
                # Check for log files
                log_file="${build_dir}/log"
                if [ -f "$log_file" ]; then
                    # Check if log was created today
                    file_date=$(date -r "$log_file" +%Y-%m-%d)
                    if [ "$file_date" = "$TODAY" ]; then
                        build_number=$(basename "$build_dir")
                        destination="${s3_job_path}/build-${build_number}.log"
                        echo "Uploading ${job_name} build ${build_number} log to S3..."
                        upload_to_s3 "$log_file" "$destination"
                    fi
                fi
            fi
        done
    fi
done

echo "Jenkins log backup completed successfully."