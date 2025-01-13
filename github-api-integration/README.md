# Github API Integration

This script lists name of the users who have access to a particular repository on Github.

## To run the script locally, follow the below steps:

```bash
sudo apt update
sudo apt install jq -y

# Clone the repository and grant necessary permissions.**
git clone https://github.com/aqeeladil/shell-scripting-projects.git
cd shell-scripting-projects/github-api-integration
chmod +x list_users.sh

# Export your github username & token
export username = "YOUR_GITHUB_USERNAME"
export token = "YOUR_GITHUB_TOKEN"

# Execute the script.
./list_users.sh TARGET_ORGANIZATION_NAME TARGET_REPO_NAME
```









