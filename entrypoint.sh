#!/bin/bash
set -e

# Ensure /home/node/.claude has correct permissions
# This is needed because Docker volumes might be created with wrong ownership
if [ -d /home/node/.claude ]; then
    # Fix ownership of .claude directory (exclude read-only agents mount)
    sudo chown node:node /home/node/.claude 2>/dev/null || true
fi

# Ensure /workspace has correct permissions
# This is needed because Docker volumes might be created with wrong ownership
if [ -d /workspace ]; then
    sudo chown -R node:node /workspace 2>/dev/null || true
fi

# Setup git credentials if PAT is available and not already configured
if [ -n "$AZURE_DEVOPS_PAT" ] && [ ! -f ~/.git-credentials ]; then
    echo "Setting up git credentials..."
    git config --global credential.helper store
    git config --global user.email "user@example.com" 2>/dev/null || true
    git config --global user.name "Docker User" 2>/dev/null || true

    # Create credentials file with PAT
    cat > ~/.git-credentials << EOF
https://${AZURE_DEVOPS_PAT}@dev.azure.com
EOF
    chmod 600 ~/.git-credentials
    echo "Git credentials configured automatically!"
fi

# Setup Azure DevOps CLI if PAT and ORG are available
if [ -n "$AZURE_DEVOPS_PAT" ] && [ -n "$AZURE_DEVOPS_ORG" ]; then
    echo "Configuring Azure DevOps CLI..."
    az extension add --name azure-devops 2>/dev/null || true
    az devops configure --defaults organization="$AZURE_DEVOPS_ORG" 2>/dev/null || true
    echo "$AZURE_DEVOPS_PAT" | az devops login --organization "$AZURE_DEVOPS_ORG" 2>/dev/null || true
fi

# Execute the main command
exec "$@"
