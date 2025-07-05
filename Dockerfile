# Dockerfile for Claude Auto Runner
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CLAUDE_RUNNER_VERSION=1.0.0

# Install required packages
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    gzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the script and related files
COPY claude-auto-runner.sh /app/
COPY test_claude_auto_runner.sh /app/
COPY security_check.sh /app/

# Make scripts executable
RUN chmod +x /app/*.sh

# Create log directory
RUN mkdir -p /app/logs

# Create a non-root user to run the application
RUN useradd -m -s /bin/bash claude-runner && \
    chown -R claude-runner:claude-runner /app

# Switch to non-root user
USER claude-runner

# Set default environment variables
ENV LOG_DIR=/app/logs
ENV DANGEROUS_MODE=true

# Volume for logs
VOLUME ["/app/logs"]

# Entry point with default parameters
ENTRYPOINT ["/app/claude-auto-runner.sh"]

# Default command arguments (can be overridden)
CMD ["--dangerous", "--log-dir", "/app/logs"]