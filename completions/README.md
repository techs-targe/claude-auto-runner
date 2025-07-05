# Shell Completion for Claude Auto Runner

This directory contains shell completion files for bash and zsh to provide tab completion for `claude-auto-runner.sh` options.

## Installation

### Bash Completion

#### Method 1: Source in current session
```bash
source completions/claude-auto-runner.bash
```

#### Method 2: Add to ~/.bashrc
```bash
echo "source /path/to/claude-auto-runner/completions/claude-auto-runner.bash" >> ~/.bashrc
source ~/.bashrc
```

#### Method 3: System-wide installation
```bash
sudo cp completions/claude-auto-runner.bash /etc/bash_completion.d/
```

### Zsh Completion

#### Method 1: Add to fpath in ~/.zshrc
```bash
# Add this to your ~/.zshrc
fpath=(~/path/to/claude-auto-runner/completions $fpath)
autoload -Uz compinit && compinit
```

#### Method 2: System-wide installation
```bash
sudo cp completions/_claude-auto-runner /usr/local/share/zsh/site-functions/
```

#### Method 3: Oh My Zsh users
```bash
cp completions/_claude-auto-runner ~/.oh-my-zsh/completions/
```

## Features

### Bash Completion
- Complete all command-line options
- Directory completion for `--log-dir`
- File completion for `--config` (filters .conf files)
- Suggested values for `--wait` and `--max-log-size`

### Zsh Completion
- Complete all command-line options with descriptions
- Directory completion for `--log-dir`
- File completion for `--config` (filters .conf files)
- Descriptive suggestions for `--wait` and `--max-log-size`
- Support for multiple `--error-pattern` options

## Testing Completion

After installation, test the completion:

```bash
# Type this and press TAB
./claude-auto-runner.sh --<TAB>

# Should show all available options
./claude-auto-runner.sh --log-dir <TAB>

# Should show directory suggestions
./claude-auto-runner.sh --config <TAB>

# Should show .conf files
```

## Troubleshooting

### Bash
- Ensure bash-completion package is installed
- Run `complete -p | grep claude` to verify registration
- Try `source /etc/bash_completion` if completions aren't working

### Zsh
- Run `echo $fpath` to see completion directories
- Run `which _claude_auto_runner` to verify the function is loaded
- Try `rm ~/.zcompdump*` and restart shell to rebuild completion cache