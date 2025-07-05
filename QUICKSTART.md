# Quick Start Guide - Claude Auto Runner

Get up and running with Claude Auto Runner in 5 minutes!

## Prerequisites

- Claude CLI installed and configured
- Bash shell (Linux, macOS, or WSL on Windows)
- Git (for cloning the repository)

## Installation

```bash
# Clone the repository
git clone git@github.com:techs-targe/claude-auto-runner.git
cd claude-auto-runner

# Make the script executable
chmod +x claude-auto-runner.sh

# (Optional) Run tests to verify installation
./test_claude_auto_runner.sh
```

## Your First Run

### 1. Test with Help
```bash
./claude-auto-runner.sh --help
```

### 2. Simple Test Run
```bash
# Run a simple test (will execute once then exit on "stop")
./claude-auto-runner.sh --dangerous \
  -m1 "Say hello and then say stop" \
  -m2 "Did you say stop?"
```

### 3. Real Task Example
```bash
# Have Claude help with a coding task
./claude-auto-runner.sh --dangerous \
  -m1 "Create a simple Python hello world script" \
  -m2 "Is the script complete and working?"
```

## Essential Options

### Must-Use Flag
- **`--dangerous`** - ALWAYS use this flag to prevent the script from hanging when Claude needs to use tools

### Recommended Options
- **`--verbose`** - See Claude's thinking process
- **`--log-dir ./logs`** - Organize logs in a separate directory
- **`--wait 10`** - Give more time between iterations for complex tasks

## Basic Workflow

1. **Prepare your tasks** - Have a clear idea of what you want Claude to do
2. **Craft your messages** - Message 1 is the task, Message 2 is the verification
3. **Run the script** - Start with `--dangerous` flag
4. **Monitor progress** - Check the logs or watch the terminal output
5. **Stop when needed** - Press Ctrl+C to stop at any time

## Example: Multi-Step Project

```bash
# Create a task list file
echo "1. Create project structure
2. Implement core functionality  
3. Add tests
4. Write documentation" > tasks.txt

# Run Claude to work through the tasks
./claude-auto-runner.sh --dangerous --verbose \
  -m1 "Work on the next task from tasks.txt" \
  -m2 "Is the current task complete with all requirements met?"
```

## Common Patterns

### Development Tasks
```bash
./claude-auto-runner.sh --dangerous \
  -m1 "Fix the next bug in the issue tracker" \
  -m2 "Is the bug fixed with tests added?"
```

### Code Review
```bash
./claude-auto-runner.sh --dangerous \
  -m1 "Review and improve code quality in the next file" \
  -m2 "Are all improvements tested and documented?"
```

### Learning Projects
```bash
./claude-auto-runner.sh --dangerous \
  -m1 "Create the next example from the tutorial" \
  -m2 "Does the example work correctly?"
```

## Monitoring and Logs

### Check Current Log
```bash
# View the current log file
tail -f claudelog_$(date +%Y%m%d).log
```

### Log Rotation
Logs are automatically rotated when they reach 10MB (configurable with `--max-log-size`)

## Stopping Execution

### Graceful Stop
- Press **Ctrl+C** - Cleanly stops execution and cleans up

### Automatic Stop
The script stops when it detects:
- "API ERROR" (default)
- "stop" (default)
- Any custom error patterns you define

## Tips for Success

1. **Start Simple** - Test with basic tasks first
2. **Be Specific** - Clear instructions get better results  
3. **Use Verification** - Message 2 should verify task completion
4. **Check Logs** - Review logs to understand what happened
5. **Iterate** - Adjust your messages based on results

## Next Steps

- Read [EXAMPLES.md](EXAMPLES.md) for advanced usage scenarios
- Check the [README.md](README.md) for all available options
- Run `./security_check.sh` to verify security settings
- Customize error patterns for your workflow

## Need Help?

- Run `./claude-auto-runner.sh --help` for option reference
- Check logs for error messages
- Review examples for similar use cases
- Submit issues on GitHub for bugs or feature requests

Happy automating! 🚀