# Script to automate the process of listing all the resources in an AWS account (using ec2 and cli setup)
  
### 1. Launch an EC2 Ubuntu machine, SSH into your instance and update it

```bash
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
sudo apt update && sudo apt upgrade -y
```

### 2. Install and configure Aws CLI:

```bash
# Install awscli
sudo apt install awscli curl unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Configure awscli (Obtain ```Access-Key-ID``` and ```Secret-Access-Key``` from the AWS Management Console).
aws configure
```

### 3. Execute the script

```bash
chmod +x aws_resources.sh
./aws_resources.sh us-east-1 ec2
```

### 4. Cron Job for Automation

```bash
crontab -e

# for daily execution at 9 PM
0 21 * * * /path/to/aws_resources.sh us-east-1 ec2 > /path/to/output.log
```


