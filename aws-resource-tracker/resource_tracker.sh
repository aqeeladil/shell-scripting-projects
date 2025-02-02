#!/bin/bash

###############################################################################
# Author: Aqeel
# Date: 07/07/2024
# Description: Reports AWS resource usage (S3, EC2, Lambda, IAM users)
# Version: v2

# set -x: debug mode
# set -e: exists the script when there is an error 
###############################################################################

# Script configuration
set -o errexit  # Exit on error
set -o nounset  # Exit on undefined variables
set -o pipefail # Exit on pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Function to check if AWS CLI is installed and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not installed${NC}"
        echo "Please install AWS CLI and configure credentials"
        exit 1
    fi

    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: AWS credentials not configured${NC}"
        echo "Please run 'aws configure' to set up your credentials"
        exit 1
    fi
}

# Function to print section headers
print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}"
}

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to list S3 buckets with size and creation date
list_s3_buckets() {
    print_header "S3 Buckets"
    aws s3api list-buckets --query 'Buckets[].{Name:Name,CreationDate:CreationDate}' --output table || 
        handle_error "Failed to list S3 buckets"
    
    echo -e "\n${YELLOW}Calculating bucket sizes (this may take a while)...${NC}"
    for bucket in $(aws s3 ls | awk '{print $3}'); do
        size=$(aws s3api list-objects-v2 --bucket "$bucket" --query 'sum(Contents[].Size)' --output text 2>/dev/null || echo "0")
        if [ "$size" != "None" ] && [ "$size" != "0" ]; then
            size_gb=$(echo "scale=2; $size/1024/1024/1024" | bc)
            echo -e "Bucket: $bucket - Size: ${size_gb}GB"
        else
            echo -e "Bucket: $bucket - Empty"
        fi
    done
}

# Function to list EC2 instances with details
list_ec2_instances() {
    print_header "EC2 Instances"
    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table ||
        handle_error "Failed to list EC2 instances"
}

# Function to list Lambda functions with runtime and memory
list_lambda_functions() {
    print_header "Lambda Functions"
    aws lambda list-functions --query 'Functions[].[FunctionName,Runtime,MemorySize]' --output table ||
        handle_error "Failed to list Lambda functions"
}

# Function to list IAM users with creation date and last login
list_iam_users() {
    print_header "IAM Users"
    aws iam list-users --query 'Users[].[UserName,CreateDate,PasswordLastUsed]' --output table ||
        handle_error "Failed to list IAM users"
}

# Main execution
main() {
    echo -e "${GREEN}AWS Resource Usage Report - $(date)${NC}"
    echo -e "${YELLOW}Account: $(aws sts get-caller-identity --query Account --output text)${NC}"
    echo -e "${YELLOW}Region: $(aws configure get region)${NC}\n"

    check_aws_cli
    
    # Execute each function in a try-catch manner
    list_s3_buckets
    list_ec2_instances
    list_lambda_functions
    list_iam_users
}

# Execute main function
main "$@"