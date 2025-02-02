# AWS Resource Tracker

A script that reports the usage of resources on your AWS account. You can integrate this script with a Cron job to execute it at a specified date and time automatically.

## Setup Instructions

Follow the steps below to set up the project locally:

### 1. Update Your System

Before installing dependencies, update your package list:

```bash
sudo apt update
```

### 2. Clone the Repository

Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/aqeeladil/shell-scripting-projects.git
cd shell-scripting-projects/aws-resource-tracker
chmod +x resource_tracker.sh
```

### 3. Install AWS CLI

Ensure AWS CLI is installed on your system:

```bash
# Download and install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### 4. Configure AWS CLI

Obtain your `Access Key ID` and `Secret Access Key` from the AWS Management Console and configure AWS CLI:

```bash
aws configure
```

### 5. Schedule the Script with a Cron Job

To run the script automatically every 5 minutes and append output to `outputFile.txt`, follow these steps:

1. Open the Cron job editor:

    ```bash
    crontab -e
    ```

2. Add the following line at the end of the file:

    ```bash
    */5 * * * * /path/to/resource_tracker.sh >> /path/to/outputFile.txt
    ```

3. Save and exit the editor.
4. To verify the scheduled Cron job:

    ```bash
    crontab -l
    ```

5. To check the output:

    ```bash
    cat /path/to/outputFile.txt
    ```

