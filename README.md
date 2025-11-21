# Claude Code with SpecKit - Docker Setup

This repository provides a Dockerized environment for running Claude Code with SpecKit and a comprehensive set of custom agents. All agents are source-controlled within this repository for easy version management and team collaboration.

## Features

- Claude Code CLI pre-installed
- SpecKit integration
- 24 custom agents organized by category:
  - **Coordination**: orchestrator
  - **Implementation**: python-backend-dev, react-typescript-specialist, stagehand-expert
  - **Research & Planning**: angular-expert, azure-devops-pipelines-expert, azure-monitor-logs-expert, chatgpt-expert, csharp-expert, figma-expert, maui-expert, mcp-builder-expert, nextjs-expert, prd-writer, pull-requests-expert, shadcn-expert, system-architect, ui-designer, youtube-api-expert
  - **Testing**: api-backend-tester, api-frontend-tester
  - **Setup & Tools**: claude-code-setup-expert, docker-expert, speckit-expert
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
docker-compose exec claude-code bash
```

Or, attach to the running container:

```bash
docker attach claude-code-container
```

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
├── workspace/                       # Your projects go here (gitignored)
├── .env.example                     # Example environment variables
├── .gitignore
├── docker-compose.yml
├── Dockerfile
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

### Available Agents

All agents are pre-loaded and ready to use. You can reference them in your Claude Code sessions:

- **Coordination**: For orchestrating complex multi-step tasks
- **Implementation**: For hands-on coding in Python, React/TypeScript, and more
- **Research & Planning**: For architecture, design, and planning tasks
- **Testing**: For API and frontend testing

### Updating Agents

To update an agent:

1. Edit the corresponding `.md` file in the `agents/` directory
2. Rebuild the Docker image:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

### Adding New Agents

1. Add the new agent file to the appropriate subdirectory in `agents/`
2. Rebuild the Docker image
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
- `claude-code-config:/root/.claude`: Persistent Claude Code configuration
- `./agents:/root/.claude/agents:ro`: Agents (read-only)

### Optional: Git Configuration

To use git inside the container with your credentials, uncomment these lines in `docker-compose.yml`:

```yaml
# - ~/.gitconfig:/root/.gitconfig:ro
# - ~/.ssh:/root/.ssh:ro
```

## Troubleshooting

### API Key Not Working

Ensure your `.env` file is in the same directory as `docker-compose.yml` and contains a valid API key.

### Agents Not Loading

Verify that the agents are mounted correctly:

```bash
docker-compose exec claude-code ls -la /root/.claude/agents/
```

### Permission Issues

If you encounter permission issues with the workspace, you may need to adjust the ownership:

```bash
docker-compose exec claude-code chown -R root:root /workspace
```

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
