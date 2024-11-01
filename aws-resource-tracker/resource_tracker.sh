#!/bin/bash

##############
# Author: Aqeel
# Date: 07/07/2024
# This script reports the AWS resource usage (s3, ec2, lambda, iam user)
# Version: v1
##############


# debug mode
set -x
# exists the script when there is an error   
set -e 
# exists the script when there is an error in the pipe command line   
set -o pipefail    


# list s3 buckets
echo "Print list of s3 buckets"
aws s3 ls

# list of ec2 instances(only instance Id's) 
echo "Print list of ec2 instances"
aws ec2 describe-instances | jq ' .Reservations[].Instances[].InstanceId '

# list lambda functions
echo "Print list of lambda functions"
aws list lambda-functions

# list IAM users
echo "Print list of IAM users"
aws iam list-users

