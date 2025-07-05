#!/bin/bash
# claude-auto-runner.sh - Automated Claude execution script with configurable options

# Default values
DANGEROUS_MODE=false
LOG_DIR="."
MESSAGE1="next Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
MESSAGE2="Have you finished testing and verification? You haven't deviated from the design document on your own judgment, right? If the content deviates, please read the design document and modify it to match the design specifications. Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
ERROR_PATTERNS=("API ERROR" "stop")
WAIT_TIME=5

# Function to display help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Automated Claude execution script that runs Claude commands in a loop with error detection.

OPTIONS:
    -h, --help                          Show this help message and exit
    -d, --dangerous                     Enable dangerous mode (--dangerously-skip-permissions)
    -l, --log-dir DIR                   Set log file directory (default: current directory)
    -m1, --message1 "MESSAGE"           Set first command message
    -m2, --message2 "MESSAGE"           Set second command message
    -e, --error-pattern "PATTERN"       Add error pattern to check (can be used multiple times)
    -c, --clear-errors                  Clear default error patterns before adding new ones
    -w, --wait SECONDS                  Set wait time between iterations (default: 5)

EXAMPLES:
    # Run with default settings
    $0

    # Run in dangerous mode with custom log directory
    $0 --dangerous --log-dir /var/log/claude

    # Run with custom messages
    $0 -m1 "Custom first message" -m2 "Custom second message"

    # Run with custom error patterns
    $0 --clear-errors --error-pattern "ERROR" --error-pattern "FAIL"

    # Run with all options
    $0 -d -l ./logs -m1 "Do task X" -m2 "Verify task X" -e "CRITICAL" -w 10

DEFAULT ERROR PATTERNS:
    - API ERROR
    - stop

NOTES:
    - Press Ctrl+C to stop the execution at any time
    - All outputs are logged to claudelog_YYYYMMDD.log in the specified directory
    - The script will automatically exit if any error pattern is detected

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dangerous)
            DANGEROUS_MODE=true
            shift
            ;;
        -l|--log-dir)
            LOG_DIR="$2"
            shift 2
            ;;
        -m1|--message1)
            MESSAGE1="$2"
            shift 2
            ;;
        -m2|--message2)
            MESSAGE2="$2"
            shift 2
            ;;
        -e|--error-pattern)
            ERROR_PATTERNS+=("$2")
            shift 2
            ;;
        -c|--clear-errors)
            ERROR_PATTERNS=()
            shift
            ;;
        -w|--wait)
            WAIT_TIME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate log directory
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: Log directory '$LOG_DIR' does not exist"
    exit 1
fi

# Setup log file
LOG_FILE="${LOG_DIR}/claudelog_$(date +%Y%m%d).log"
echo "Logging to: ${LOG_FILE}"

# Build Claude command options
CLAUDE_OPTS=""
if [[ "$DANGEROUS_MODE" == true ]]; then
    CLAUDE_OPTS="--dangerously-skip-permissions"
fi

# Function to check for error patterns
check_response() {
    local response="$1"
    
    for pattern in "${ERROR_PATTERNS[@]}"; do
        if [[ "$response" =~ "$pattern" ]]; then
            echo "Error pattern detected: $pattern"
            return 1
        fi
    done
    
    return 0
}

# Display configuration
echo "Configuration:"
echo "  Dangerous mode: $DANGEROUS_MODE"
echo "  Log directory: $LOG_DIR"
echo "  Wait time: $WAIT_TIME seconds"
echo "  Error patterns: ${ERROR_PATTERNS[*]}"
echo ""

# Main loop
echo "Starting automated Claude execution..."
echo "Press Ctrl+C to stop at any time"
echo ""

while true; do
    echo -e "\n=== $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"
    
    # First claude command
    echo "Executing first command..." | tee -a "$LOG_FILE"
    echo "Message: $MESSAGE1" | tee -a "$LOG_FILE"
    response=$(claude $CLAUDE_OPTS -c -p "$MESSAGE1" 2>&1)
    echo "$response" | tee -a "$LOG_FILE"
    
    if ! check_response "$response"; then
        echo "Error detected in first command. Exiting..." | tee -a "$LOG_FILE"
        break
    fi
    
    # Second claude command
    echo -e "\nExecuting second command..." | tee -a "$LOG_FILE"
    echo "Message: $MESSAGE2" | tee -a "$LOG_FILE"
    response=$(claude $CLAUDE_OPTS -p -c "$MESSAGE2" 2>&1)
    echo "$response" | tee -a "$LOG_FILE"
    
    if ! check_response "$response"; then
        echo "Error detected in second command. Exiting..." | tee -a "$LOG_FILE"
        break
    fi
    
    # Ask user for continuation
    echo -e "\nContinue? (Press Ctrl+C to stop, will continue in $WAIT_TIME seconds...)" | tee -a "$LOG_FILE"
    sleep "$WAIT_TIME"
done

echo "Execution completed." | tee -a "$LOG_FILE"
