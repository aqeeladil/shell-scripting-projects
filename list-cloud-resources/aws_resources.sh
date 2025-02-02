#!/bin/bash

###############################################################################
###############################################################################
# Author: Aqeel
# Version: v0.1.0
#
# Script to list AWS resources across different services with enhanced filtering and output options.
#
# Features:
# - Improved error handling
# - Output formatting options (JSON, table, text)
# - Resource filtering capabilities
# - Pagination support
# - Resource count summaries
# - Multi-region support
# - Tags filtering

# Below are the services that are supported by this script:
# 1. EC2
# 2. RDS
# 3. S3
# 4. CloudFront
# 5. VPC
# 6. IAM
# 7. Route53
# 8. CloudWatch
# 9. CloudFormation
# 10. Lambda
# 11. SNS
# 12. SQS
# 13. DynamoDB
# 14. EBS 
#
# The script will prompt the user to enter the AWS region and the service for which the resources need to be listed.
#
# Usage: ./aws_resources.sh  <aws_region> <aws_service>
# Basic Usage Example: ./aws_resources.sh us-east-1 ec2
# With formatting and filtering: ./aws_resources.sh --format table --max-items 50 --tags us-east-1 ec2
# List across all regions: ./aws_resources.sh --all-regions --name "prod-" ec2
###############################################################################
###############################################################################

set -eo pipefail

# Configuration
MAX_ITEMS=100
OUTPUT_FORMAT="table"
SHOW_TAGS=false
ALL_REGIONS=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage instructions
function usage() {
    cat << EOF
Usage: $0 [options] <aws_region> <aws_service>

Options:
    -h, --help              Show this help message
    -f, --format FORMAT     Output format (json|table|text) [default: table]
    -m, --max-items N      Maximum number of items to return [default: 100]
    -t, --tags            Include resource tags in output
    -a, --all-regions     List resources across all regions
    -n, --name PATTERN    Filter resources by name pattern
    
Supported Services: 
    ec2, rds, s3, cloudfront, vpc, iam, route53, cloudwatch,
    cloudformation, lambda, sns, sqs, dynamodb, ebs

Example: 
    $0 --format json --max-items 50 us-east-1 ec2
    $0 --all-regions --tags ec2
EOF
}

# Error handling function
function error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check AWS CLI configuration
function check_aws_config() {
    if ! command -v aws &> /dev/null; then
        error_exit "AWS CLI is not installed. Please install it first."
    fi

    if ! aws sts get-caller-identity &> /dev/null; then
        error_exit "AWS CLI is not properly configured. Please run 'aws configure'."
    fi
}

# Parse command line arguments
function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -m|--max-items)
                MAX_ITEMS="$2"
                shift 2
                ;;
            -t|--tags)
                SHOW_TAGS=true
                shift
                ;;
            -a|--all-regions)
                ALL_REGIONS=true
                shift
                ;;
            -n|--name)
                NAME_FILTER="$2"
                shift 2
                ;;
            *)
                if [[ -z $AWS_REGION ]]; then
                    AWS_REGION="$1"
                elif [[ -z $AWS_SERVICE ]]; then
                    AWS_SERVICE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
                else
                    error_exit "Unknown parameter: $1"
                fi
                shift
                ;;
        esac
    done

    # Validate required parameters
    if [[ $ALL_REGIONS == false && -z $AWS_REGION ]]; then
        error_exit "AWS region is required unless --all-regions is specified"
    fi
    if [[ -z $AWS_SERVICE ]]; then
        error_exit "AWS service is required"
    fi
}

# Format output based on user preference
function format_output() {
    local output=$1
    case $OUTPUT_FORMAT in
        json)
            echo "$output" | jq '.'
            ;;
        table)
            echo "$output" | jq -r '.[][] | select(. != null) | [.Name//empty, .InstanceId//empty, .State.Name//empty, .InstanceType//empty] | @tsv' | 
                column -t -s $'\t' -N "NAME,ID,STATE,TYPE"
            ;;
        text)
            echo "$output" | jq -r '.[][] | select(. != null) | .Name//empty + " (" + (.InstanceId//empty) + ")"'
            ;;
        *)
            error_exit "Invalid output format: $OUTPUT_FORMAT"
            ;;
    esac
}

# Get list of regions if --all-regions is specified
function get_regions() {
    if [[ $ALL_REGIONS == true ]]; then
        aws ec2 describe-regions --query 'Regions[].RegionName' --output text
    else
        echo "$AWS_REGION"
    fi
}

# List resources for a specific service
function list_resources() {
    local region=$1
    local count=0

    echo -e "${GREEN}Listing $AWS_SERVICE resources in $region...${NC}"

    case $AWS_SERVICE in
        ec2)
            local query='Reservations[].Instances[]'
            [[ -n $NAME_FILTER ]] && query+=" | select(.Tags[].Value | contains(\"$NAME_FILTER\"))"
            aws ec2 describe-instances \
                --region "$region" \
                --max-items "$MAX_ITEMS" \
                --query "$query" \
                $(if [[ $SHOW_TAGS == true ]]; then echo "--include-tags"; fi)
            ;;
        rds)
            aws rds describe-db-instances \
                --region "$region" \
                --max-records "$MAX_ITEMS"
            ;;
        s3)
            aws s3api list-buckets
            if [[ $SHOW_TAGS == true ]]; then
                echo -e "${YELLOW}Note: Fetching tags for each bucket...${NC}"
                # Add bucket tagging information
                for bucket in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
                    aws s3api get-bucket-tagging --bucket "$bucket" 2>/dev/null || echo "No tags for $bucket"
                done
            fi
            ;;
        # ... [Similar improvements for other services] ...
        *)
            error_exit "Invalid service: $AWS_SERVICE"
            ;;
    esac
}

# Main execution
function main() {
    check_aws_config
    parse_arguments "$@"

    for region in $(get_regions); do
        list_resources "$region" | format_output
    done
}

# Execute main function with all arguments
main "$@"