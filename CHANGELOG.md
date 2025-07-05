# Changelog

All notable changes to Claude Auto Runner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Docker support with Dockerfile and docker-compose.yml
- Docker documentation (DOCKER.md)
- Docker-related Makefile targets (docker-build, docker-run, docker-up, docker-down)
- .dockerignore file for optimized builds
- Docker support test in test suite
- Configuration file support (.claude-runner.conf)
- --config option to specify custom configuration file
- Example configuration file (.claude-runner.conf.example)
- Configuration loading from multiple locations (current dir, home, /etc)
- Configuration file tests in test suite
- Shell completion support for bash and zsh
- Completion files with installation instructions
- make install-completions target for easy setup
- Tab completion for all options, directories, and config files

## [1.0.0] - 2025-01-05

### Added
- Initial release of Claude Auto Runner
- Automated execution with configurable loop
- Error detection with customizable patterns
- Dangerous mode (`--dangerous`) for skipping permissions
- Verbose mode (`--verbose`) for detailed output
- Log file management with automatic rotation and compression
- Signal handling for graceful shutdown (Ctrl+C)
- Configurable wait time between iterations
- Custom message support for both execution steps
- Input validation for all parameters
- Retry logic with exponential backoff (3 attempts)
- Automatic log directory creation
- Claude CLI existence check
- Comprehensive test suite
- Security validation script
- GitHub Actions CI/CD workflow
- Quick Start guide (QUICKSTART.md)
- Examples documentation (EXAMPLES.md)
- Version information (`--version` flag)

### Security
- Set secure umask (077) for file creation
- Validate log directory permissions
- Input sanitization for all user inputs
- No hardcoded credentials
- Safe temporary file handling

### Documentation
- Comprehensive README with all features documented
- Quick Start guide for new users
- Practical examples for common use cases
- Test suite documentation
- Security check documentation