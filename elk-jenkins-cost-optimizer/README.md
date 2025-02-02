# Jenkins Log Management: Automated S3 Backup Solution for Cost Reduction

## Problem Statement

The client was facing high costs due to excessive storage of Jenkins logs in a self-hosted ELK (Elasticsearch, Logstash, Kibana) stack. The logs, though rarely analyzed, contributed significantly to storage and infrastructure expenses.

## Use Case

The client had a self-hosted ELK stack to manage logs from multiple sources, including:

- Application logs from 100+ microservices.
- Kubernetes control plane logs.
- Infrastructure logs, primarily from Jenkins.

### Issues with ELK Stack for Jenkins Logs

1. **Costly Storage**: Jenkins logs generated across various environments (UAT, staging, production) added a substantial financial burden due to:
   - Frequent builds triggered by 100+ developers.
   - Logs generated even for trivial or dummy commits.
   - Thousands of log files produced daily.

2. **Underutilization**: Jenkins logs stored in ELK were rarely analyzed. Instead:
   - Developers relied on email and Slack notifications for build failures.
   - Logs were stored primarily as backups rather than for real-time troubleshooting.

## Solution

To optimize costs, Jenkins logs were moved from ELK to AWS S3, leveraging lifecycle policies for efficient storage management.

### Key Actions:
- Automate the daily transfer of Jenkins logs from the Jenkins server to an AWS S3 bucket using a shell script.
- Store only essential logs, reducing redundant storage in ELK.
- Use S3 lifecycle policies to transition older logs to cheaper storage tiers (e.g., Glacier, Deep Archive).

## Implementation Steps

### 1. Identify Jenkins Log Storage Directory

Jenkins logs are typically stored in:

```
/var/lib/jenkins/jobs/
├── job1/
│   ├── builds/
│   │   ├── 1/log
│   │   ├── 2/log
│   │   ├── ...
├── job2/
│   ├── builds/
│   │   ├── 1/log
│   │   ├── 2/log
```

### 2. Set Up an AWS S3 Bucket

- Create an S3 bucket for storing Jenkins logs (e.g., `jenkins-logs-backup`).
- Enable lifecycle policies to automatically move older logs to lower-cost storage tiers like Glacier or Deep Archive.

### 3. Install and Configure AWS CLI on Jenkins Server

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Configure AWS CLI
aws configure  # Provide Access Key ID and Secret Access Key from AWS Management Console
```

### 4. Automate Backup Using a Scheduled Script

Create a shell script (`jenkins-s3-backup.sh`) and schedule it to run nightly using cron.

```bash
crontab -e

chmod +x jenkins-s3-backup.sh

0 0 * * * /path/to/jenkins-s3-backup.sh
```

## Outcomes

- **Cost Reduction**: Eliminating Jenkins logs from ELK reduced storage and compute costs by 50%.
- **Automated Storage Management**: Logs older than 3 months are automatically moved to cheaper S3 tiers.
- **Simplified Implementation**: A lightweight solution using a basic shell script, avoiding complex plugins or third-party tools.

This solution provides an efficient, scalable, and cost-effective way to manage Jenkins logs while reducing ELK stack overhead.

