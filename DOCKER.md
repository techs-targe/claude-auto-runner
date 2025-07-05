# Docker Support for Claude Auto Runner

This guide explains how to run Claude Auto Runner in a Docker container.

## Prerequisites

- Docker installed (version 20.10 or later)
- Docker Compose installed (version 2.0 or later)
- Claude CLI configuration files (if using Claude CLI)

## Quick Start

### 1. Build the Docker Image

```bash
docker build -t claude-auto-runner:latest .
```

### 2. Run with Docker

```bash
# Basic run
docker run -v $(pwd)/logs:/app/logs claude-auto-runner:latest

# With custom parameters
docker run -v $(pwd)/logs:/app/logs claude-auto-runner:latest \
  --dangerous --verbose --wait 10

# With Claude config mounted (if using Claude CLI)
docker run \
  -v $(pwd)/logs:/app/logs \
  -v ~/.config/claude:/home/claude-runner/.config/claude:ro \
  claude-auto-runner:latest
```

### 3. Run with Docker Compose

```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

## Configuration

### Environment Variables

You can configure the runner using environment variables:

```yaml
environment:
  - LOG_DIR=/app/logs
  - DANGEROUS_MODE=true
  - WAIT_TIME=10
  - MAX_LOG_SIZE=52428800  # 50MB
```

### Volumes

The following volumes are available:

- `/app/logs` - Log files directory
- `/home/claude-runner/.config/claude` - Claude CLI configuration

### Custom Messages

To use custom messages, override the command:

```bash
docker run -v $(pwd)/logs:/app/logs claude-auto-runner:latest \
  --dangerous \
  -m1 "Your first message" \
  -m2 "Your second message"
```

Or in docker-compose.yml:

```yaml
command: [
  "--dangerous",
  "-m1", "Your first message",
  "-m2", "Your second message"
]
```

## Advanced Usage

### Building for Different Architectures

```bash
# Build for ARM64 (e.g., Apple Silicon)
docker buildx build --platform linux/arm64 -t claude-auto-runner:arm64 .

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  -t claude-auto-runner:multiarch .
```

### Using with CI/CD

Example GitHub Actions workflow:

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v4
  with:
    context: .
    push: true
    tags: |
      ghcr.io/${{ github.repository }}:latest
      ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### Resource Limits

The docker-compose.yml includes resource limits:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
```

Adjust these based on your needs.

### Health Checks

The container includes a health check that verifies the script is running:

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-f", "claude-auto-runner.sh"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Debugging

### View Container Logs

```bash
# Docker
docker logs -f <container_id>

# Docker Compose
docker-compose logs -f claude-runner
```

### Access Container Shell

```bash
# Docker
docker exec -it <container_id> /bin/bash

# Docker Compose
docker-compose exec claude-runner /bin/bash
```

### Use Log Viewer Service

```bash
# Start with debug profile
docker-compose --profile debug up -d

# This will tail the log files continuously
docker-compose logs -f log-viewer
```

## Security Considerations

1. **Non-root User**: The container runs as `claude-runner` user, not root
2. **Read-only Config**: Mount Claude config as read-only (`:ro`)
3. **Resource Limits**: Set appropriate CPU and memory limits
4. **Volume Permissions**: Ensure proper permissions on mounted volumes

## Troubleshooting

### Permission Denied on Logs

```bash
# Fix permissions on host
mkdir -p logs
chmod 755 logs
```

### Claude CLI Not Working

Ensure you mount the Claude configuration:

```bash
-v ~/.config/claude:/home/claude-runner/.config/claude:ro
```

### Container Exits Immediately

Check if error patterns are being triggered:

```bash
docker logs <container_id>
```

## Example Deployment

Here's a complete example for production deployment:

```bash
# Create necessary directories
mkdir -p logs claude-config

# Copy your Claude config (if needed)
cp -r ~/.config/claude/* claude-config/

# Create .env file
cat > .env <<EOF
CLAUDE_RUNNER_VERSION=1.0.0
WAIT_TIME=30
MAX_LOG_SIZE=104857600
EOF

# Start the service
docker-compose up -d

# Monitor logs
docker-compose logs -f
```

## Updating

To update to a new version:

```bash
# Pull latest changes
git pull

# Rebuild image
docker-compose build --no-cache

# Restart service
docker-compose up -d
```