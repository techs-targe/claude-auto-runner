#!/bin/bash
# Bash completion for claude-auto-runner.sh
# Install: source completions/claude-auto-runner.bash
# Or add to ~/.bashrc: source /path/to/claude-auto-runner/completions/claude-auto-runner.bash

_claude_auto_runner_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # All available options
    opts="-h --help --version -d --dangerous -v --verbose -l --log-dir -m1 --message1 -m2 --message2 -e --error-pattern -c --clear-errors -w --wait --max-log-size --config"
    
    # Handle option-specific completions
    case "${prev}" in
        -l|--log-dir)
            # Complete directory names
            COMPREPLY=( $(compgen -d -- "${cur}") )
            return 0
            ;;
        --config)
            # Complete .conf files
            COMPREPLY=( $(compgen -f -X '!*.conf' -- "${cur}") )
            # Also include common config file names
            if [[ -z "${cur}" ]]; then
                COMPREPLY+=( ".claude-runner.conf" )
            fi
            return 0
            ;;
        -w|--wait|--max-log-size)
            # Suggest common values
            if [[ "${prev}" == "-w" || "${prev}" == "--wait" ]]; then
                COMPREPLY=( $(compgen -W "1 5 10 30 60" -- "${cur}") )
            elif [[ "${prev}" == "--max-log-size" ]]; then
                COMPREPLY=( $(compgen -W "1048576 5242880 10485760 52428800 104857600" -- "${cur}") )
            fi
            return 0
            ;;
        -m1|--message1|-m2|--message2|-e|--error-pattern)
            # No completion for message/pattern arguments
            return 0
            ;;
    esac
    
    # Complete options if current word starts with -
    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

# Register the completion function
complete -F _claude_auto_runner_completions claude-auto-runner.sh
complete -F _claude_auto_runner_completions ./claude-auto-runner.sh

# Also register for the installed version if it exists
if command -v claude-auto-runner.sh >/dev/null 2>&1; then
    complete -F _claude_auto_runner_completions $(command -v claude-auto-runner.sh)
fi