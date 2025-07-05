# Makefile for Claude Auto Runner

# Variables
SCRIPT_NAME = claude-auto-runner.sh
INSTALL_DIR = /usr/local/bin
VERSION = $(shell grep "^VERSION=" $(SCRIPT_NAME) | cut -d'"' -f2)

# Default target
.DEFAULT_GOAL := help

# Phony targets
.PHONY: help install uninstall test security-check lint clean update-version release docker-build docker-run docker-compose-up docker-compose-down install-completions

# Help target
help:
	@echo "Claude Auto Runner Makefile"
	@echo "=========================="
	@echo ""
	@echo "Available targets:"
	@echo "  make install       - Install the script to $(INSTALL_DIR)"
	@echo "  make uninstall     - Remove the script from $(INSTALL_DIR)"
	@echo "  make test          - Run the test suite"
	@echo "  make security      - Run security checks"
	@echo "  make lint          - Run shellcheck (if installed)"
	@echo "  make clean         - Clean up log files and temporary files"
	@echo "  make release       - Create a new release (updates version)"
	@echo "  make install-completions - Install shell completions (bash/zsh)"
	@echo ""
	@echo "Docker targets:"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run in Docker container"
	@echo "  make docker-up     - Start with docker-compose"
	@echo "  make docker-down   - Stop docker-compose services"
	@echo ""
	@echo "Current version: $(VERSION)"

# Install target
install:
	@echo "Installing Claude Auto Runner..."
	@if [ ! -f "$(SCRIPT_NAME)" ]; then \
		echo "Error: $(SCRIPT_NAME) not found!"; \
		exit 1; \
	fi
	@echo "Copying scripts to $(INSTALL_DIR)..."
	@sudo cp $(SCRIPT_NAME) $(INSTALL_DIR)/$(SCRIPT_NAME)
	@sudo chmod 755 $(INSTALL_DIR)/$(SCRIPT_NAME)
	@if [ -f "claude-log-analyzer.sh" ]; then \
		sudo cp claude-log-analyzer.sh $(INSTALL_DIR)/claude-log-analyzer.sh; \
		sudo chmod 755 $(INSTALL_DIR)/claude-log-analyzer.sh; \
		echo "Log analyzer installed"; \
	fi
	@echo "Installation complete!"
	@echo "You can now run 'claude-auto-runner.sh' from anywhere."

# Uninstall target
uninstall:
	@echo "Uninstalling Claude Auto Runner..."
	@if [ -f "$(INSTALL_DIR)/$(SCRIPT_NAME)" ]; then \
		sudo rm -f $(INSTALL_DIR)/$(SCRIPT_NAME); \
		echo "Main script removed"; \
	fi
	@if [ -f "$(INSTALL_DIR)/claude-log-analyzer.sh" ]; then \
		sudo rm -f $(INSTALL_DIR)/claude-log-analyzer.sh; \
		echo "Log analyzer removed"; \
	fi
	@echo "Uninstallation complete!"

# Test target
test:
	@echo "Running test suite..."
	@if [ -x "./test_claude_auto_runner.sh" ]; then \
		./test_claude_auto_runner.sh; \
	else \
		echo "Error: test_claude_auto_runner.sh not found or not executable!"; \
		exit 1; \
	fi

# Security check target
security-check security:
	@echo "Running security checks..."
	@if [ -x "./security_check.sh" ]; then \
		./security_check.sh; \
	else \
		echo "Error: security_check.sh not found or not executable!"; \
		exit 1; \
	fi

# Lint target
lint:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -S error $(SCRIPT_NAME); \
		echo "Shellcheck passed!"; \
	else \
		echo "Warning: shellcheck is not installed."; \
		echo "Install it to run syntax checks."; \
	fi

# Clean target
clean:
	@echo "Cleaning up..."
	@rm -f claudelog_*.log
	@rm -f claudelog_*.log.*.gz
	@rm -f *.tmp
	@rm -f *~
	@echo "Cleanup complete!"

# Update version (for maintainers)
update-version:
	@if [ -z "$(NEW_VERSION)" ]; then \
		echo "Error: Please specify NEW_VERSION=x.y.z"; \
		exit 1; \
	fi
	@echo "Updating version to $(NEW_VERSION)..."
	@sed -i.bak 's/^VERSION=".*"/VERSION="$(NEW_VERSION)"/' $(SCRIPT_NAME)
	@sed -i.bak 's/^# Version: .*/# Version: $(NEW_VERSION)/' $(SCRIPT_NAME)
	@rm -f $(SCRIPT_NAME).bak
	@echo "Version updated to $(NEW_VERSION)"
	@echo "Don't forget to update CHANGELOG.md!"

# Release target
release: test security-check lint
	@echo "==================================="
	@echo "Pre-release checks passed!"
	@echo "==================================="
	@echo ""
	@echo "Current version: $(VERSION)"
	@echo ""
	@echo "To create a release:"
	@echo "1. Update version: make update-version NEW_VERSION=x.y.z"
	@echo "2. Update CHANGELOG.md"
	@echo "3. Commit changes"
	@echo "4. Create git tag: git tag -a v\$${VERSION} -m 'Release v\$${VERSION}'"
	@echo "5. Push: git push origin main --tags"

# Check dependencies
check-deps:
	@echo "Checking dependencies..."
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "Warning: 'claude' command not found. Please install Claude CLI."; \
	else \
		echo "✓ Claude CLI is installed"; \
	fi
	@if ! command -v bash >/dev/null 2>&1; then \
		echo "Error: bash is required!"; \
		exit 1; \
	else \
		echo "✓ Bash is installed"; \
	fi

# Development setup
dev-setup: check-deps
	@echo "Setting up development environment..."
	@chmod +x $(SCRIPT_NAME)
	@chmod +x test_claude_auto_runner.sh
	@chmod +x security_check.sh
	@chmod +x claude-log-analyzer.sh
	@chmod +x setup-dev.sh
	@echo "Development setup complete!"

# Docker targets
docker-build:
	@echo "Building Docker image..."
	@docker build -t claude-auto-runner:$(VERSION) -t claude-auto-runner:latest .
	@echo "Docker image built successfully!"

docker-run: docker-build
	@echo "Running Claude Auto Runner in Docker..."
	@mkdir -p logs
	@docker run -it --rm \
		-v $(PWD)/logs:/app/logs \
		claude-auto-runner:latest

docker-up:
	@echo "Starting Claude Auto Runner with docker-compose..."
	@docker-compose up -d
	@echo "Claude Auto Runner is running in the background."
	@echo "View logs with: docker-compose logs -f"

docker-down:
	@echo "Stopping Claude Auto Runner..."
	@docker-compose down
	@echo "Claude Auto Runner stopped."

docker-logs:
	@docker-compose logs -f claude-runner

# Shell completion installation
install-completions:
	@echo "Installing shell completions..."
	@if [ -n "$${BASH_VERSION}" ]; then \
		if [ -d /etc/bash_completion.d ]; then \
			echo "Installing bash completion system-wide..."; \
			sudo cp completions/claude-auto-runner.bash /etc/bash_completion.d/; \
		else \
			echo "Adding bash completion to ~/.bashrc..."; \
			echo "source $(PWD)/completions/claude-auto-runner.bash" >> ~/.bashrc; \
			echo "Run 'source ~/.bashrc' to activate"; \
		fi; \
	elif [ -n "$${ZSH_VERSION}" ]; then \
		if [ -d ~/.oh-my-zsh/completions ]; then \
			echo "Installing zsh completion for Oh My Zsh..."; \
			cp completions/_claude-auto-runner ~/.oh-my-zsh/completions/; \
		elif [ -w /usr/local/share/zsh/site-functions ]; then \
			echo "Installing zsh completion system-wide..."; \
			sudo cp completions/_claude-auto-runner /usr/local/share/zsh/site-functions/; \
		else \
			echo "Add this to your ~/.zshrc:"; \
			echo "fpath=($(PWD)/completions \$$fpath)"; \
		fi; \
	else \
		echo "Unknown shell. See completions/README.md for manual installation."; \
	fi