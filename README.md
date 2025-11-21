# Claude Code with SpecKit - Docker Setup

This repository provides a Dockerized environment for running Claude Code with SpecKit and a comprehensive set of custom agents. All agents are source-controlled within this repository for easy version management and team collaboration.

## Features

- **Claude Code CLI** pre-installed (official setup)
- **SpecKit integration** for structured development
- **Custom slash commands** for streamlined workflows:
  - **SpecKit commands**: specify, plan, tasks, implement, analyze, clarify, checklist, constitution
  - **Captur commands**: design-angular-feature, design-csharp-feature, implement-angular-feature, implement-csharp-feature, review-current-branch, devops-prompt-engineer
  - **Dev commands**: design-backend, design-app, implement-backend, implement-app, prompt-engineer
- **24 custom agents** organized by category:
  - **Coordination**: orchestrator
  - **Implementation**: python-backend-dev, react-typescript-specialist, stagehand-expert
  - **Research & Planning**: angular-expert, azure-devops-pipelines-expert, azure-monitor-logs-expert, chatgpt-expert, csharp-expert, figma-expert, maui-expert, mcp-builder-expert, nextjs-expert, prd-writer, pull-requests-expert, shadcn-expert, system-architect, ui-designer, youtube-api-expert
  - **Testing**: api-backend-tester, api-frontend-tester
  - **Setup & Tools**: claude-code-setup-expert, docker-expert, speckit-expert
- **Enhanced Developer Experience**:
  - Zsh shell with plugins (git, fzf) and auto-completion
  - Git-delta for beautiful git diffs
  - Persistent command history across sessions
  - GitHub CLI (gh) pre-installed
  - Full development toolset (jq, vim, nano, etc.)
- **Security**: Runs as non-root user with proper permissions
- Persistent workspace for your projects
- Git and essential development tools included

## Prerequisites

- Docker installed on your system
- Docker Compose (included with Docker Desktop)
- Anthropic API key ([get one here](https://console.anthropic.com/settings/keys))

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ai-claude-code-docker
```

### 2. Set Up Your API Key

Copy the example environment file and add your API key:

```bash
cp .env.example .env
```

Edit `.env` and replace `your_api_key_here` with your actual Anthropic API key:

```
ANTHROPIC_API_KEY=sk-ant-xxxxx
```

### 3. Build and Run

```bash
docker-compose up -d --build
```

### 4. Access the Container

```bash
docker-compose exec claude-code zsh
```

Or, attach to the running container:

```bash
docker attach claude-code-container
```

**Note**: The container uses `zsh` as the default shell with enhanced features like syntax highlighting and auto-completion.

### 5. Start Using Claude Code

Once inside the container, you can start Claude Code:

```bash
claude-code
```

## Project Structure

```
ai-claude-code-docker/
├── agents/                          # All custom agents (source-controlled)
│   ├── coordination/
│   │   └── orchestrator.md
│   ├── implementation/
│   │   ├── python-backend-dev.md
│   │   ├── react-typescript-specialist.md
│   │   └── stagehand-expert.md
│   ├── research-planning/
│   │   ├── angular-expert.md
│   │   ├── azure-devops-pipelines-expert.md
│   │   └── ... (more agents)
│   ├── testing/
│   │   ├── api-backend-tester.md
│   │   └── api-frontend-tester.md
│   ├── claude-code-setup-expert.md
│   ├── docker-expert.md
│   └── speckit-expert.md
├── commands/                        # All custom slash commands (source-controlled)
│   ├── captur/                      # Captur-specific commands
│   │   ├── design-angular-feature.md
│   │   ├── design-csharp-feature.md
│   │   ├── implement-angular-feature.md
│   │   ├── implement-csharp-feature.md
│   │   ├── review-current-branch.md
│   │   └── devops-prompt-engineer.md
│   ├── dev/                         # Development workflow commands
│   │   ├── design-backend.md
│   │   ├── design-app.md
│   │   ├── implement-backend.md
│   │   ├── implement-app.md
│   │   └── prompt-engineer.md
│   ├── agent_prompts/               # Agent prompt templates
│   ├── speckit.specify.md
│   ├── speckit.plan.md
│   ├── speckit.tasks.md
│   ├── speckit.implement.md
│   └── ... (more speckit commands)
├── workspace/                       # Your projects go here (gitignored)
├── .env.example                     # Example environment variables
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh                    # Startup script for permissions
├── init-firewall.sh                 # Network sandboxing script
└── README.md
```

## Usage

### Working with Projects

Your projects should be placed in the `workspace/` directory, which is mounted as a volume. This ensures your work persists between container restarts.

```bash
# Inside the container
cd /workspace
mkdir my-project
cd my-project
# Start coding with Claude Code
claude-code
```

### Available Agents and Commands

All agents and slash commands are pre-loaded and ready to use.

**Agents** - Reference with `@agent-name`:
- **Coordination**: For orchestrating complex multi-step tasks
- **Implementation**: For hands-on coding in Python, React/TypeScript, and more
- **Research & Planning**: For architecture, design, and planning tasks
- **Testing**: For API and frontend testing

**Slash Commands** - Use with `/command-name`:
- **SpecKit**: `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`, etc.
- **Captur**: `/captur:design-angular-feature`, `/captur:implement-csharp-feature`, `/captur:review-current-branch`
- **Dev**: `/dev:design-backend`, `/dev:implement-app`, `/dev:prompt-engineer`

### Updating Agents or Commands

To update an agent or slash command:

1. Edit the corresponding `.md` file in the `agents/` or `commands/` directory
2. Changes are immediately available (no rebuild needed, they're mounted as volumes)
3. To make them permanent in the image, rebuild:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

### Adding New Agents or Commands

1. Add the new file to the appropriate subdirectory in `agents/` or `commands/`
2. Restart the container (or rebuild for permanent inclusion)
3. Commit the changes to keep them source-controlled

## Managing the Container

### Start the container

```bash
docker-compose up -d
```

### Stop the container

```bash
docker-compose down
```

### Rebuild the image (after agent updates)

```bash
docker-compose up -d --build
```

### View logs

```bash
docker-compose logs -f claude-code
```

### Remove everything (including volumes)

```bash
docker-compose down -v
```

## Configuration

### Environment Variables

You can customize the container behavior by modifying environment variables in the `docker-compose.yml` file or by creating a `.env` file:

- `ANTHROPIC_API_KEY`: Your Anthropic API key (required)
- `NODE_ENV`: Node environment (default: development)

### Volume Mounts

- `./workspace:/workspace`: Your project files
- `claude-code-config:/home/node/.claude`: Persistent Claude Code configuration
- `command-history:/commandhistory`: Persistent command history across sessions
- `./agents:/home/node/.claude/agents:ro`: Agents (read-only)

### Optional: Git Configuration

To use git inside the container with your credentials, uncomment these lines in `docker-compose.yml`:

```yaml
# - ~/.gitconfig:/home/node/.gitconfig:ro
# - ~/.ssh:/home/node/.ssh:ro
```

## Troubleshooting

### API Key Not Working

Ensure your `.env` file is in the same directory as `docker-compose.yml` and contains a valid API key.

### Agents Not Loading

Verify that the agents are mounted correctly:

```bash
docker-compose exec claude-code ls -la /home/node/.claude/agents/
```

### Permission Issues

The container runs as the `node` user (non-root) for security. If you encounter permission issues with the workspace, check file ownership. Files created in the container will be owned by the `node` user (UID 1000).

## Contributing

To contribute new agents or improvements:

1. Fork the repository
2. Make your changes to the agent files in `agents/`
3. Test the changes by rebuilding the Docker image
4. Submit a pull request

## License

[Specify your license here]

## Support

For issues related to:
- Claude Code: Visit [Claude Code GitHub](https://github.com/anthropics/claude-code)
- SpecKit: Visit the SpecKit documentation
- This Docker setup: Open an issue in this repository
