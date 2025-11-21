#!/bin/bash
# Setup git credentials using Azure DevOps PAT

if [ -z "$AZURE_DEVOPS_PAT" ]; then
    echo "Error: AZURE_DEVOPS_PAT environment variable not set"
    exit 1
fi

echo "Setting up git credentials for Azure DevOps..."

# Configure git credential helper
git config --global credential.helper store

# Configure git user (update with your info if needed)
git config --global user.email "user@example.com"
git config --global user.name "Docker User"

# Create credentials file with PAT for Azure DevOps
mkdir -p ~/.config/git
cat > ~/.git-credentials << EOF
https://${AZURE_DEVOPS_PAT}@dev.azure.com
EOF

chmod 600 ~/.git-credentials

echo "Git credentials configured successfully!"
echo "You can now clone repos without entering credentials."
