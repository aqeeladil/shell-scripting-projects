
#!/bin/bash

###############################################################################
# Author: Aqeel
# Version: v0.0.1

# Script to automate the process of listing all the resources in an AWS account
#
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
# Example: ./aws_resources.sh us-east-1 ec2
#############################################################################

# Usage instructions
function usage() {
    echo "Usage: $0 <aws_region> <aws_service>"
    echo "Example: $0 us-east-1 ec2"
    echo "Supported Services: ec2, rds, s3, cloudfront, vpc, iam, route53, cloudwatch,"
    echo "cloudformation, lambda, sns, sqs, dynamodb, ebs"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install the AWS CLI and try again."
    exit 1
fi

# Check arguments
if [[ "$1" == "--help" || "$1" == "-h" || $# -ne 2 ]]; then
    usage
    exit 0
fi

# Assign arguments
aws_region=$1
aws_service=$(echo "$2" | tr '[:upper:]' '[:lower:]')

# Check if AWS CLI is configured
if [ ! -d ~/.aws ]; then
    echo "AWS CLI is not configured. Please configure it and try again."
    exit 1
fi

# List resources based on the service
case $aws_service in
    ec2)
        echo "Listing EC2 Instances in $aws_region..."
        aws ec2 describe-instances --region "$aws_region" | jq || aws ec2 describe-instances --region "$aws_region"
        ;;
    rds)
        echo "Listing RDS Instances in $aws_region..."
        aws rds describe-db-instances --region "$aws_region" | jq || aws rds describe-db-instances --region "$aws_region"
        ;;
    s3)
        echo "Listing S3 Buckets (Global)..."
        aws s3api list-buckets | jq || aws s3api list-buckets
        ;;
    cloudfront)
        echo "Listing CloudFront Distributions (Global)..."
        aws cloudfront list-distributions | jq || aws cloudfront list-distributions
        ;;
    vpc)
        echo "Listing VPCs in $aws_region..."
        aws ec2 describe-vpcs --region "$aws_region" | jq || aws ec2 describe-vpcs --region "$aws_region"
        ;;
    iam)
        echo "Listing IAM Users (Global)..."
        aws iam list-users | jq || aws iam list-users
        ;;
    route53)
        echo "Listing Route53 Hosted Zones (Global)..."
        aws route53 list-hosted-zones | jq || aws route53 list-hosted-zones
        ;;
    cloudwatch)
        echo "Listing CloudWatch Alarms in $aws_region..."
        aws cloudwatch describe-alarms --region "$aws_region" | jq || aws cloudwatch describe-alarms --region "$aws_region"
        ;;
    cloudformation)
        echo "Listing CloudFormation Stacks in $aws_region..."
        aws cloudformation describe-stacks --region "$aws_region" | jq || aws cloudformation describe-stacks --region "$aws_region"
        ;;
    lambda)
        echo "Listing Lambda Functions in $aws_region..."
        aws lambda list-functions --region "$aws_region" | jq || aws lambda list-functions --region "$aws_region"
        ;;
    sns)
        echo "Listing SNS Topics in $aws_region..."
        aws sns list-topics --region "$aws_region" | jq || aws sns list-topics --region "$aws_region"
        ;;
    sqs)
        echo "Listing SQS Queues in $aws_region..."
        aws sqs list-queues --region "$aws_region" | jq || aws sqs list-queues --region "$aws_region"
        ;;
    dynamodb)
        echo "Listing DynamoDB Tables in $aws_region..."
        aws dynamodb list-tables --region "$aws_region" | jq || aws dynamodb list-tables --region "$aws_region"
        ;;
    ebs)
        echo "Listing EBS Volumes in $aws_region..."
        aws ec2 describe-volumes --region "$aws_region" | jq || aws ec2 describe-volumes --region "$aws_region"
        ;;
    *)
        echo "Invalid service: $aws_service"
        usage
        exit 1
        ;;
esac
