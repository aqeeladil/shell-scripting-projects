# GitHub API Integration

This script retrieves and lists the names of users who have access to a specific repository on GitHub.

## Prerequisites

Ensure you have the following installed on your system:
- `jq` (A lightweight and flexible command-line JSON processor)
- `git`

## Installation

Follow these steps to set up and run the script locally:

### 1. Update and Install Dependencies
```bash
sudo apt update
sudo apt install jq git -y
```

### 2. Clone the Repository and Set Permissions
```bash
git clone https://github.com/aqeeladil/shell-scripting-projects.git
cd shell-scripting-projects/github-api-integration
chmod +x list_users.sh
```

### 3. Configure GitHub Credentials
Set your GitHub credentials either in environment variables or in `.github-credentials`:
```bash
export username="YOUR_GITHUB_USERNAME"
export token="YOUR_GITHUB_TOKEN"
```
**Note:** Ensure that your GitHub token has the necessary permissions to access repository details.

### 4. Run the Script
Execute the script with the target organization and repository name:
```bash
./list_users.sh TARGET_ORGANIZATION_NAME TARGET_REPO_NAME
```

## Notes
- Replace `YOUR_GITHUB_USERNAME` and `YOUR_GITHUB_TOKEN` with your actual credentials.
- Ensure your token has the required scopes (`repo` for private repositories, `read:org` for organization repositories).
- The script relies on GitHub's API rate limits, so ensure your token has sufficient request quota.




