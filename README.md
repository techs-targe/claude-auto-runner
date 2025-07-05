# Claude Auto Runner

Automated Claude Code execution script that runs tasks in a loop.

## How It Works

This automation script leverages Claude Code's non-interactive mode to execute task queries and verification queries in an infinite loop. This enables Claude Code to continuously process tasks even while you're sleeping or working on other things.

The script operates with a two-query structure:
- **MESSAGE1**: Executes the main task query
- **MESSAGE2**: Performs verification and checks the response

By default, MESSAGE1 instructs Claude to execute the next task with full effort, while MESSAGE2 verifies that the implementation follows the design specifications and hasn't deviated from requirements.

### Recommended Workflow

It's recommended to organize your tasks in a queue for sequential execution. In my personal setup, I've designed prompts so that Claude executes the next task when instructed with "next". This creates a smooth workflow where tasks are processed one after another automatically.

You can easily modify the messages using Claude Code to fit your specific use case and workflow requirements.

## Usage

```bash
./claude-auto-runner.sh
```

## Options

- `-d, --dangerous`: Skip permissions
- `-m1 "MESSAGE"`: First message
- `-m2 "MESSAGE"`: Second message

## License

MIT