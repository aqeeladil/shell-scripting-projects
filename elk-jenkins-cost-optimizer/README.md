# Jenkins Log Management: Automated S3 Backup Solution for Cost Reduction"

## Problem Statement: 

High cost of ELK stack due to unnecessary storage of Jenkins logs.

## Use Case

- The client had a self-hosted ELK stack (Elasticsearch, Logstash, Kibana) to manage logs from various sources:

    - Application logs from 100+ microservices.

    - Kubernetes control plane logs.

    - Infrastructure logs, primarily from Jenkins.

- **Issues with ELK Stack for Jenkins Logs:**

    - *Costly Storage:* The client was using a self-hosted ELK stack on virtual machines with connected volumes. Jenkins logs, generated across multiple environments (UAT, staging, production), were creating a significant financial burden due to:

        - Frequent builds triggered by 100+ developers.

        - Logs generated even for trivial or dummy commits.

        - Thousands of log files produced daily.

    - *Underutilization:* Jenkins logs stored in the ELK stack were not analyzed. Instead:

        - Developers used email and Slack notifications to debug build failures.

        - Logs were stored merely as a backup, not for active troubleshooting or analysis.

## Solution

- Move Jenkins logs out of the ELK stack and store them in AWS S3, which is cheaper and supports lifecycle management.

- Use a shell script to automate the daily transfer of Jenkins logs from the Jenkins server to an S3 bucket.

- Keep only essential logs and avoid redundant storage in the ELK stack.

- Use S3’s lifecycle policies to automatically move older logs to cheaper storage tiers like Glacier.

## Implementation Steps

1. **Jenkins Log Storage Directory:**

    - Jenkins stores logs for jobs under `/var/lib/jenkins/jobs/`.

    - Each job has a `builds` directory containing log files (e.g., `build1.log`, `build2.log`, etc.) for individual builds. For Example: 
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

2. **AWS S3 Bucket:**

    - Create an S3 bucket to store the Jenkins logs.

    - Name the bucket, (e.g., `jenkins-logs-backup`).

    - Configure lifecycle management to automatically move old logs to cheaper storage tiers like Glacier or Deep Archive.

3. **AWS CLI Installation on Jenkins server:**

    ```
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version

    # Configure awscli (Obtain ```Access-Key-ID``` and ```Secret-Access-Key``` from the AWS Management  Console).
    aws configure
    ```

4. **Schedule the script to run nightly using a cron job, ensuring daily uploads of new logs.**

```bash
crontab -e

chmod +x jenkins-s3-backup.sh

0 0 * * * jenkins-s3-backup.sh
```

## Outcomes

- **Cost Savings:** Moving logs to S3 reduces ELK storage and compute costs by 50%.

- **Lifecycle Management:** Logs older than 3 months are automatically moved to cheaper tiers (e.g., Glacier).

- **Simple Implementation:** The solution avoids complex plugins and uses a straightforward shell script.