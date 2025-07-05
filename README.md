# Claude Auto Runner

Automated Claude Code execution script with configurable options for running tasks while you sleep.

## Overview

This script automates the execution of Claude Code commands in a loop, allowing you to run complex tasks unattended. It includes error detection, logging, and customizable messages.

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

## Installation

1. Clone this repository:
```bash
git clone git@github.com:techs-targe/claude-auto-runner.git
cd claude-auto-runner
```

2. Make the script executable:
```bash
chmod +x autocc.sh
```

## Usage

### Basic Usage

```bash
./autocc.sh
```

### Advanced Options

```bash
# Run in dangerous mode with custom log directory
./autocc.sh --dangerous --log-dir /var/log/claude

# Run with custom messages
./autocc.sh -m1 "Custom first message" -m2 "Custom second message"

# Run with custom error patterns
./autocc.sh --clear-errors --error-pattern "ERROR" --error-pattern "FAIL"

# Run with all options
./autocc.sh -d -l ./logs -m1 "Do task X" -m2 "Verify task X" -e "CRITICAL" -w 10
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message and exit |
| `-d, --dangerous` | Enable dangerous mode (--dangerously-skip-permissions) |
| `-l, --log-dir DIR` | Set log file directory (default: current directory) |
| `-m1, --message1 "MESSAGE"` | Set first command message |
| `-m2, --message2 "MESSAGE"` | Set second command message |
| `-e, --error-pattern "PATTERN"` | Add error pattern to check (can be used multiple times) |
| `-c, --clear-errors` | Clear default error patterns before adding new ones |
| `-w, --wait SECONDS` | Set wait time between iterations (default: 5) |

## Default Messages

1. **First Message**: "next Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
2. **Second Message**: "Have you finished testing and verification? You haven't deviated from the design document on your own judgment, right? If the content deviates, please read the design document and modify it to match the design specifications. Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."

## Default Error Patterns

- `API ERROR`
- `stop`

## Logging

All outputs are logged to `claudelog_YYYYMMDD.log` in the specified directory.

## Notes

- Press `Ctrl+C` to stop the execution at any time
- The script will automatically exit if any error pattern is detected
- Each iteration includes a pause to allow for manual intervention

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.