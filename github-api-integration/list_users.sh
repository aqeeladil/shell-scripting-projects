#!/bin/bash

##########################################
# Author: Aqeel
# Description: Lists users who have access to a specified GitHub repository
# Usage: ./script.sh <repo_owner> <repo_name>
# Requirements: 
#   - curl
#   - jq
#   - GitHub personal access token with repo scope
##########################################

set -euo pipefail

# Configuration
readonly API_URL="https://api.github.com"

# Load GitHub credentials from environment or config file
if [[ -f ~/.github-credentials ]]; then
    source ~/.github-credentials
else
    : "${GITHUB_USERNAME:?'GITHUB_USERNAME environment variable is not set'}"
    : "${GITHUB_TOKEN:?'GITHUB_TOKEN environment variable is not set'}"
fi

# Helper function for displaying usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <repo_owner> <repo_name>

Lists all users who have access to the specified GitHub repository.

Arguments:
    repo_owner  - Owner of the repository
    repo_name   - Name of the repository

Environment variables:
    GITHUB_USERNAME - Your GitHub username
    GITHUB_TOKEN    - Your GitHub personal access token

Example:
    $(basename "$0") octocat hello-world
EOF
    exit 1
}

# Function to validate dependencies
check_dependencies() {
    local missing_deps=0
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command '$cmd' not found"
            missing_deps=1
        fi
    done
    
    if [[ $missing_deps -eq 1 ]]; then
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Function to make a GET request to the GitHub API
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    local response
    local http_code

    # Temporary file for response headers
    local headers_tmp
    headers_tmp=$(mktemp)
    
    response=$(curl -s -w "%{http_code}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -o >(cat) -D "$headers_tmp" \
        "$url")
    
    http_code=${response: -3}
    body=${response::-3}
    
    rm -f "$headers_tmp"

    if [[ $http_code -eq 404 ]]; then
        echo "Error: Repository not found or no access permissions" >&2
        exit 1
    elif [[ $http_code -eq 401 ]]; then
        echo "Error: Authentication failed. Please check your GitHub token" >&2
        exit 1
    elif [[ $http_code -ne 200 ]]; then
        echo "Error: GitHub API request failed with status $http_code" >&2
        echo "Response: $body" >&2
        exit 1
    fi

    echo "$body"
}

# Function to list users with repository access
list_repository_access() {
    local repo_owner="$1"
    local repo_name="$2"
    local endpoint="repos/${repo_owner}/${repo_name}/collaborators"

    echo "Fetching access information for ${repo_owner}/${repo_name}..."
    
    # Fetch and process collaborators
    local collaborators
    collaborators=$(github_api_get "$endpoint")
    
    # Parse and display results using jq
    echo -e "\nAccess Levels:"
    echo "$collaborators" | jq -r '
        .[] | select(.permissions != null) | 
        if .permissions.admin == true then
            .login + ": Admin"
        elif .permissions.maintain == true then
            .login + ": Maintain"
        elif .permissions.push == true then
            .login + ": Write"
        elif .permissions.pull == true then
            .login + ": Read"
        else
            .login + ": Unknown access level"
        end
    ' | sort

    # Display total count
    local total_users
    total_users=$(echo "$collaborators" | jq '. | length')
    echo -e "\nTotal users with access: $total_users"
}

main() {
    # Check dependencies first
    check_dependencies

    # Validate command line arguments
    if [[ $# -ne 2 ]]; then
        usage
    fi

    local repo_owner="$1"
    local repo_name="$2"

    # Validate input
    if [[ ! $repo_owner =~ ^[a-zA-Z0-9_-]+$ ]] || [[ ! $repo_name =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Error: Invalid repository owner or name format" >&2
        usage
    fi

    # Execute main functionality
    list_repository_access "$repo_owner" "$repo_name"
}

# Execute main function with all command line arguments
main "$@"