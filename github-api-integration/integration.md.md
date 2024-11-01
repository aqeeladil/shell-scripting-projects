# Github API Integration
This script lists name of the users who have access to a particular repository on Github.

<br>

**To run the script locally, follow the below steps:**

1. ***Set up the environment (Ubuntu)***
```bash
sudo apt update
sudo apt install jq -y
```
<br>

2. Clone the repository and grant necessary permissions.
```bash
git clone https://github.com/aqeeladil/github-api-integration.git
```
```bash
cd github-api-integration
```
```bash
chmod +x list_users.sh
```

<br>

3. Export your github username & token  <br>
```bash
export username = "YOUR_GITHUB_USERNAME"
```
```bash
export token = "YOUR_GITHUB_TOKEN"
```

<br>

4. Execute the script.
```bash
./list_users.sh TARGET_ORGANIZATION_NAME TARGET_REPO_NAME
```

<br><br>







