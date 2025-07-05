# Claude Auto Runner

[![Test Claude Auto Runner](https://github.com/techs-targe/claude-auto-runner/actions/workflows/test.yml/badge.svg)](https://github.com/techs-targe/claude-auto-runner/actions/workflows/test.yml)

Automated Claude Code execution script with configurable options for running tasks while you sleep.

## Overview

This script automates the execution of Claude Code commands in a loop, allowing you to run complex tasks unattended. It includes error detection, logging, and customizable messages.

## Quick Links

- 🚀 [Quick Start Guide](QUICKSTART.md) - Get started in 5 minutes
- 📚 [Examples & Use Cases](EXAMPLES.md) - Practical scenarios and patterns
- 🔧 [Troubleshooting](TROUBLESHOOTING.md) - Solve common issues
- 🤝 [Contributing](CONTRIBUTING.md) - How to contribute
- 📝 [Changelog](CHANGELOG.md) - Version history
- 🔒 [Security Check](security_check.sh) - Validate security settings
- 🧪 [Test Suite](test_claude_auto_runner.sh) - Run comprehensive tests

## How It Works

This automation script leverages Claude Code's non-interactive mode to execute task queries and verification queries in an infinite loop. This enables Claude Code to continuously process tasks even while you're sleeping or working on other things.

The script operates with a two-query structure:
- **MESSAGE1**: Executes the main task query
- **MESSAGE2**: Performs verification and checks the response

By default, MESSAGE1 instructs Claude to execute the next task with full effort, while MESSAGE2 verifies that the implementation follows the design specifications and hasn't deviated from requirements.

### Recommended Workflow

It's recommended to organize your tasks in a queue for sequential execution. In my personal setup, I've designed prompts so that Claude executes the next task when instructed with "next". This creates a smooth workflow where tasks are processed one after another automatically.

You can easily modify the messages using Claude Code to fit your specific use case and workflow requirements.

## Features

- **Automated Execution**: Run Claude commands in a continuous loop
- **Error Detection**: Automatically stops when errors are detected
- **Flexible Configuration**: Customize messages, error patterns, and timing
- **Comprehensive Logging**: All outputs are logged with timestamps
- **Dangerous Mode**: Option to skip permissions for advanced usage
- **Custom Error Patterns**: Define your own error detection patterns
- **Verbose Mode**: Option to see Claude's detailed thinking process
- **Log File Management**: Automatic log rotation and compression when files exceed size limits
- **Signal Handling**: Graceful shutdown with Ctrl+C and proper cleanup
- **Improved Error Handling**: Better pattern matching and error detection
- **Iteration Tracking**: Progress tracking with numbered iterations

## Installation

### Quick Install

1. Clone this repository:
```bash
git clone git@github.com:techs-targe/claude-auto-runner.git
cd claude-auto-runner
```

2. Install using make (recommended):
```bash
make install
```

### Manual Install

1. Clone the repository (as above)

2. Make the script executable:
```bash
chmod +x claude-auto-runner.sh
```

3. Optionally, copy to your PATH:
```bash
sudo cp claude-auto-runner.sh /usr/local/bin/
```

## Usage

### Basic Usage

```bash
./claude-auto-runner.sh
```

### Advanced Options

```bash
# Run in dangerous mode with custom log directory
./claude-auto-runner.sh --dangerous --log-dir /var/log/claude

# Run with custom messages
./claude-auto-runner.sh -m1 "Custom first message" -m2 "Custom second message"

# Run with custom error patterns
./claude-auto-runner.sh --clear-errors --error-pattern "ERROR" --error-pattern "FAIL"

# Run with all options
./claude-auto-runner.sh -d -l ./logs -m1 "Do task X" -m2 "Verify task X" -e "CRITICAL" -w 10

# Run with custom log file size limit (in bytes)
./claude-auto-runner.sh --dangerous --max-log-size 52428800  # 50MB
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message and exit |
| `-d, --dangerous` | Enable dangerous mode (--dangerously-skip-permissions) |
| `-v, --verbose` | Enable verbose output to see Claude's thinking process |
| `-l, --log-dir DIR` | Set log file directory (default: current directory) |
| `-m1, --message1 "MESSAGE"` | Set first command message |
| `-m2, --message2 "MESSAGE"` | Set second command message |
| `-e, --error-pattern "PATTERN"` | Add error pattern to check (can be used multiple times) |
| `-c, --clear-errors` | Clear default error patterns before adding new ones |
| `-w, --wait SECONDS` | Set wait time between iterations (default: 5) |
| `--max-log-size SIZE` | Set maximum log file size in bytes (default: 10MB) |

## Default Messages

1. **First Message**: "next Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
2. **Second Message**: "Have you finished testing and verification? You haven't deviated from the design document on your own judgment, right? If the content deviates, please read the design document and modify it to match the design specifications. Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."

## Default Error Patterns

- `API ERROR`
- `stop`

## Logging

All outputs are logged to `claudelog_YYYYMMDD.log` in the specified directory.

### Log File Management

- **Automatic Rotation**: Log files are automatically rotated when they exceed the maximum size limit (default: 10MB)
- **Compression**: Old log files are compressed with gzip to save disk space
- **Timestamped Archives**: Rotated logs are archived with timestamps (e.g., `claudelog_20240101.log.20240101_143022.gz`)
- **Size Control**: You can customize the maximum log file size using the `--max-log-size` option

## Notes

- Press `Ctrl+C` to stop the execution at any time
- The script will automatically exit if any error pattern is detected
- Each iteration includes a pause to allow for manual intervention
- The script now includes improved error handling and pattern matching
- Log files are automatically managed with rotation and compression
- Use `--verbose` mode to see Claude's detailed thinking process during execution
- Signal handling ensures proper cleanup of temporary files on exit

## License

MIT License - see LICENSE file for details

## Testing

The project includes a comprehensive test suite to ensure reliability:

```bash
# Run the test suite
./test_claude_auto_runner.sh
```

The test suite includes:
- Syntax validation
- Function existence checks
- Default value verification
- Error pattern validation
- Signal handling tests
- Log rotation functionality
- Command-line argument parsing
- File permission checks
- ShellCheck validation (if installed)

### Continuous Integration

This project uses GitHub Actions for automated testing on every push and pull request. Tests are run on both Ubuntu and macOS to ensure cross-platform compatibility.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.