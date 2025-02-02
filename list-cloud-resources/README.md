# AWS Resource Listing Automation

This script automates the process of listing all resources in an AWS account using EC2 and AWS CLI.

## Prerequisites
Ensure you have the following before proceeding:
- An AWS account
- SSH access to an EC2 Ubuntu instance
- AWS CLI installed and configured

## 1. Launch an EC2 Instance and Connect via SSH

Start by launching an Ubuntu EC2 instance from the AWS Management Console. Once the instance is running, connect to it using SSH:

```bash
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
sudo apt update && sudo apt upgrade -y
```

## 2. Install and Configure AWS CLI

Install AWS CLI and configure it with your credentials:

```bash
# Install AWS CLI and dependencies
sudo apt install awscli curl unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Configure AWS CLI (You will need your Access Key ID and Secret Access Key)
aws configure
```

## 3. Execute the Script

Once AWS CLI is set up, make the script executable and run it:

```bash
chmod +x aws_resources.sh
./aws_resources.sh us-east-1 ec2
```

Replace `us-east-1` with your desired AWS region and `ec2` with the AWS resource type you wish to list.

## 4. Automate Execution with a Cron Job

To run the script automatically every day at 9 PM, set up a cron job:

```bash
crontab -e
```

Add the following line at the end of the file:

```bash
0 21 * * * /path/to/aws_resources.sh us-east-1 ec2 > /path/to/output.log 2>&1
```

This schedules the script to run daily at 9 PM and logs output to `output.log`.

