# Aws Resource Tracker

A script that reports the usage of resources on your Aws account. You can also integrate this script with Cronjob, and then Cronjob will execute the script at your specified date and time.

## To set up the project locally, follow the below steps:

1. **Set up the environment (Ubuntu)**

    `sudo apt update`

2. **Clone the repository**

    ```bash
    git clone https://github.com/aqeeladil/shell-scripting-projects.git
    
    cd shell-scripting-projects/aws-resource-tracker

    chmod +x resource_tracker.sh
    ```

3. **Aws CLI Installation**

    ```
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version

    # Configure awscli (Obtain ```Access-Key-ID``` and ```Secret-Access-Key``` from the AWS Management  Console).
    aws configure
    ```

5. **Set a Cron job to run this script every 5 minutes and append it to the outputFile.txt**

    ```bash
    crontab -e

    */5 * * * * /path/to/resource_tracker.sh >> /path/to/outputFile.txt

    crontab -l

    cat /path/to/outputfile.txt
    ```









