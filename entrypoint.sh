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

# Execute the main command
exec "$@"
