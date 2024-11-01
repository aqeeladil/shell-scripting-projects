# Aws resource tracker
A script that reports the usage of resources on your Aws account. You can also integrate this script with Cronjob, and then Cronjob will execute the script at your specified date and time.

<br>

**To set up the project locally, follow the below steps:**

1. ***Set up the environment (Ubuntu)***
```bash
sudo apt update
```
<br>

2. Clone the repository
```bash
git clone https://github.com/aqeeladil/shell-scripting-projects.git
```
```bash
cd shell-scripting-projects/aws-resource-tracker
```
```bash
chmod +x resource_tracker.sh
```

<br>

3. Aws CLI Installation <br>
Install or update to the latest version of the AWS CLI from [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

<br>

4. Configure Aws CLI using the ACCESS & SECRET ACCESS Keys
```bash
aws configure
```

<br>

5. Set a Cron job to run this script every 5 minutes and append it to the outputFile.txt
```bash
crontab -e
```
```bash
*/5 * * * * /path/to/resource_tracker.sh >> /path/to/outputFile.txt
```
```bash
crontab -l
```
```bash
cat /path/to/outputfile.txt
```
<br><br>








