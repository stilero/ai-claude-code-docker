#!/bin/bash
# Helper script to clone Azure DevOps repos using PAT from environment

if [ -z "$1" ]; then
    echo "Usage: git-clone-ado <repo-url>"
    echo ""
    echo "Examples:"
    echo "  git-clone-ado https://dev.azure.com/org/project/_git/repo"
    echo "  git-clone-ado dev.azure.com/org/project/_git/repo"
    exit 1
fi

REPO_URL="$1"

# Remove https:// if present
REPO_URL="${REPO_URL#https://}"

# Check if PAT is set
if [ -z "$AZURE_DEVOPS_PAT" ]; then
    echo "Error: AZURE_DEVOPS_PAT environment variable not set"
    echo "Please set it in your .env file"
    exit 1
fi

# Clone with PAT
echo "Cloning repository..."
git clone "https://${AZURE_DEVOPS_PAT}@${REPO_URL}"

echo "Done! Repository cloned successfully."
