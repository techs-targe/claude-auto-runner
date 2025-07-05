#!/bin/bash
# setup-dev.sh - Development environment setup for Claude Auto Runner

set -e

echo "Setting up development environment for Claude Auto Runner..."
echo ""

# Check Python
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: Python 3 is required for pre-commit hooks"
    echo "Please install Python 3 and try again"
    exit 1
fi

# Check pip
if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
    echo "Error: pip is required for pre-commit hooks"
    echo "Please install pip and try again"
    exit 1
fi

# Determine pip command
PIP_CMD="pip3"
if ! command -v pip3 >/dev/null 2>&1; then
    PIP_CMD="pip"
fi

# Install pre-commit
echo "Installing pre-commit..."
$PIP_CMD install --user pre-commit

# Add user's pip bin to PATH if needed
export PATH="$HOME/.local/bin:$PATH"

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
if command -v pre-commit >/dev/null 2>&1; then
    pre-commit install
    echo "✓ Pre-commit hooks installed successfully"
else
    echo "Error: pre-commit command not found after installation"
    echo "You may need to add $HOME/.local/bin to your PATH"
    exit 1
fi

# Run pre-commit on all files to verify setup
echo ""
echo "Running initial validation..."
if pre-commit run --all-files; then
    echo "✓ All checks passed!"
else
    echo "Some checks failed. This is normal for initial setup."
    echo "Fix any issues and run 'pre-commit run --all-files' again."
fi

# Make all scripts executable
echo ""
echo "Setting executable permissions..."
chmod +x *.sh
chmod +x completions/*.bash

# Install shell completions (optional)
echo ""
read -p "Would you like to install shell completions? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make install-completions
fi

echo ""
echo "Development environment setup complete!"
echo ""
echo "Pre-commit hooks will now run automatically before each commit."
echo "You can also run checks manually with: pre-commit run --all-files"
echo ""
echo "Happy coding! 🚀"