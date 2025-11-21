# Changelog

## [Updated] - 2025-11-21

### Major Update: Aligned with Official Claude Code Docker Setup

The Dockerfile has been completely rewritten to follow the official Claude Code example while preserving custom agent functionality.

### Added
- **Zsh shell** with plugins (git, fzf) as default shell
- **Git-delta** for enhanced git diffs with better syntax highlighting
- **Persistent command history** across container restarts
- **GitHub CLI (gh)** pre-installed for GitHub operations
- **Comprehensive development tools**: jq, aggregate, dnsutils, procps, sudo, man-db
- **Network sandboxing** via init-firewall.sh script
- **Proper npm global configuration** for the node user

### Changed
- **Security improvement**: Container now runs as `node` user (UID 1000) instead of root
- **Base image**: Changed from `node:20-slim` to `node:20` (full image with more tools)
- **User paths**: All paths changed from `/root/.claude` to `/home/node/.claude`
- **Shell**: Default shell changed from bash to zsh
- **Docker Compose**: Updated volume mounts to use `/home/node` paths
- **Command history**: Now persisted in a named volume `/commandhistory`

### Fixed
- **Security vulnerability**: Eliminated running as root user
- **Missing tools**: Added essential development tools that were missing from slim image
- **No history persistence**: Command history now persists across sessions
- **Poor developer experience**: Enhanced shell with auto-completion and better tooling

### Technical Details

#### Dockerfile Changes
- Switched from `node:20-slim` to `node:20` base image
- Added comprehensive apt packages (fzf, zsh, gh, iptables, etc.)
- Configured zsh-in-docker with git and fzf plugins
- Installed git-delta v0.18.2 for better git diffs
- Set up proper file permissions for node user
- Added init-firewall.sh script for network sandboxing
- Preserved custom agents directory copying

#### Docker Compose Changes
- Updated all volume mount paths from `/root/.claude` to `/home/node/.claude`
- Added `command-history:/commandhistory` volume for persistent history
- Updated git config mount paths to use `/home/node`

#### README Changes
- Updated all documentation to reflect non-root user setup
- Added new features section highlighting zsh, git-delta, and enhanced tooling
- Changed shell commands from `bash` to `zsh`
- Updated troubleshooting section to explain node user permissions
- Added note about UID 1000 for file ownership

### Why These Changes Matter

1. **Security**: Running as non-root follows Docker best practices and reduces attack surface
2. **Developer Experience**: Zsh with plugins, git-delta, and fzf provide modern CLI experience
3. **Compatibility**: Aligned with official Claude Code setup ensures better support
4. **Persistence**: Command history and proper volume mounts prevent data loss
5. **Tools**: Full node:20 image includes libraries needed for various development tasks

### Migration Notes

If you have an existing setup:

1. **Volumes**: Existing volumes using `/root/.claude` will not be automatically migrated
2. **To preserve your config**:
   ```bash
   docker-compose down
   docker volume rm ai-claude-code-docker_claude-code-config
   docker-compose up -d --build
   ```
3. **File permissions**: Files in `workspace/` created by the old root user may need ownership changes

### Breaking Changes

- Volume mount paths changed from `/root/.claude` to `/home/node/.claude`
- Default shell changed from bash to zsh
- Container user changed from root (UID 0) to node (UID 1000)

### Why the Previous Setup Deviated

The original `claude-code-setup-expert` agent likely:
1. Created a simplified setup without reviewing official examples
2. Used common patterns (root user, slim images) rather than Claude Code-specific requirements
3. Did not consider security best practices for Docker containers
4. Missed the enhanced developer experience features that make Claude Code containers productive
