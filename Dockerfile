# Base image with Node.js
FROM node:20-slim

# Install essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /workspace

# Create Claude Code configuration directory
RUN mkdir -p /root/.claude/agents

# Copy agents to Claude Code directory
COPY agents/ /root/.claude/agents/

# Install Claude Code CLI globally
RUN npm install -g @anthropics/claude-code

# Install SpecKit globally (assuming it's available via npm)
# If SpecKit needs to be installed differently, update this step
RUN npm install -g github-speckit || echo "SpecKit installation step - update if needed"

# Set environment variables
ENV CLAUDE_CODE_HOME=/root/.claude
ENV WORKSPACE=/workspace

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "============================================"\n\
echo "Claude Code with SpecKit - Docker Container"\n\
echo "============================================"\n\
echo ""\n\
echo "Available agents:"\n\
echo "  - claude-code-setup-expert"\n\
echo "  - speckit-expert"\n\
echo "  - docker-expert"\n\
echo "  - orchestrator"\n\
echo "  - python-backend-dev"\n\
echo "  - react-typescript-specialist"\n\
echo "  - stagehand-expert"\n\
echo "  - angular-expert"\n\
echo "  - azure-devops-pipelines-expert"\n\
echo "  - azure-monitor-logs-expert"\n\
echo "  - chatgpt-expert"\n\
echo "  - csharp-expert"\n\
echo "  - figma-expert"\n\
echo "  - maui-expert"\n\
echo "  - mcp-builder-expert"\n\
echo "  - nextjs-expert"\n\
echo "  - prd-writer"\n\
echo "  - pull-requests-expert"\n\
echo "  - shadcn-expert"\n\
echo "  - system-architect"\n\
echo "  - ui-designer"\n\
echo "  - youtube-api-expert"\n\
echo "  - api-backend-tester"\n\
echo "  - api-frontend-tester"\n\
echo ""\n\
echo "Starting interactive shell..."\n\
echo "Run '\''claude-code'\'' to start Claude Code"\n\
echo ""\n\
exec /bin/bash' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]
