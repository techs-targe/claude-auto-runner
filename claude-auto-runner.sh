#!/bin/bash
# claude-auto-runner.sh - Automated Claude execution script with configurable options

# Default values
DANGEROUS_MODE=false
VERBOSE_MODE=false
LOG_DIR="."
MESSAGE1="next Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
MESSAGE2="Have you finished testing and verification? You haven't deviated from the design document on your own judgment, right? If the content deviates, please read the design document and modify it to match the design specifications. Ultrathink, please work with full effort without holding back. If you encounter an unsolvable problem, say stop."
DEFAULT_ERROR_PATTERNS=("API ERROR" "stop")
ERROR_PATTERNS=("${DEFAULT_ERROR_PATTERNS[@]}")
WAIT_TIME=5
MAX_LOG_SIZE=10485760  # 10MB in bytes

# Cleanup function
cleanup() {
    echo -e "\n\nCleaning up..."
    # Remove temporary files
    if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
    echo "Cleanup completed."
    exit 0
}

# Setup signal handlers
trap cleanup SIGINT SIGTERM

# Function to display help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Automated Claude execution script that runs Claude commands in a loop with error detection.

OPTIONS:
    -h, --help                          Show this help message and exit
    -d, --dangerous                     Enable dangerous mode (--dangerously-skip-permissions)
                                        RECOMMENDED for automated execution
    -v, --verbose                       Enable verbose output to see Claude's thinking process
    -l, --log-dir DIR                   Set log file directory (default: current directory)
    -m1, --message1 "MESSAGE"           Set first command message
    -m2, --message2 "MESSAGE"           Set second command message
    -e, --error-pattern "PATTERN"       Add error pattern to check (can be used multiple times)
    -c, --clear-errors                  Clear default error patterns before adding new ones
    -w, --wait SECONDS                  Set wait time between iterations (default: 5)
    --max-log-size SIZE                 Set maximum log file size in bytes (default: 10MB)

EXAMPLES:
    # Run with default settings (may hang on tool usage)
    $0

    # Run in dangerous mode (RECOMMENDED for automation)
    $0 --dangerous

    # Run with verbose output to see Claude's thinking
    $0 --dangerous --verbose

    # Run in dangerous mode with custom log directory
    $0 --dangerous --log-dir /var/log/claude

    # Run with custom messages
    $0 -d -m1 "Custom first message" -m2 "Custom second message"

    # Run with custom error patterns
    $0 -d --clear-errors --error-pattern "ERROR" --error-pattern "FAIL"

    # Run with all options
    $0 -d -v -l ./logs -m1 "Do task X" -m2 "Verify task X" -e "CRITICAL" -w 10

DEFAULT ERROR PATTERNS:
    - API ERROR
    - stop

NOTES:
    - Press Ctrl+C to stop the execution at any time
    - All outputs are logged to claudelog_YYYYMMDD.log in the specified directory
    - The script will automatically exit if any error pattern is detected
    - Without --dangerous mode, the script may hang when Claude needs to use tools
    - Use --verbose to see Claude's detailed thinking process during execution
    - Log files are automatically rotated when they exceed the maximum size limit

EOF
}

# Function to rotate log file if it exceeds max size
rotate_log() {
    local log_file="$1"
    
    if [[ -f "$log_file" && $(stat -c%s "$log_file" 2>/dev/null || echo 0) -gt $MAX_LOG_SIZE ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="${log_file}.${timestamp}"
        
        echo "Log file size exceeded ${MAX_LOG_SIZE} bytes, rotating..."
        mv "$log_file" "$backup_file"
        echo "Previous log archived as: $backup_file"
        
        # Compress old log file
        gzip "$backup_file" 2>/dev/null && echo "Compressed: ${backup_file}.gz"
    fi
}

# Parse command line arguments
CLEAR_ERRORS=false
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
        -v|--verbose)
            VERBOSE_MODE=true
            shift
            ;;
        -l|--log-dir)
            if [[ -z "$2" ]]; then
                echo "Error: --log-dir requires a directory path"
                exit 1
            fi
            LOG_DIR="$2"
            shift 2
            ;;
        -m1|--message1)
            if [[ -z "$2" ]]; then
                echo "Error: --message1 requires a message"
                exit 1
            fi
            MESSAGE1="$2"
            shift 2
            ;;
        -m2|--message2)
            if [[ -z "$2" ]]; then
                echo "Error: --message2 requires a message"
                exit 1
            fi
            MESSAGE2="$2"
            shift 2
            ;;
        -e|--error-pattern)
            if [[ -z "$2" ]]; then
                echo "Error: --error-pattern requires a pattern"
                exit 1
            fi
            ERROR_PATTERNS+=("$2")
            shift 2
            ;;
        -c|--clear-errors)
            CLEAR_ERRORS=true
            shift
            ;;
        -w|--wait)
            if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: --wait requires a numeric value"
                exit 1
            fi
            WAIT_TIME="$2"
            shift 2
            ;;
        --max-log-size)
            if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: --max-log-size requires a numeric value"
                exit 1
            fi
            MAX_LOG_SIZE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Handle clear errors option
if [[ "$CLEAR_ERRORS" == true ]]; then
    ERROR_PATTERNS=()
fi

# If no error patterns after clearing, warn user
if [[ ${#ERROR_PATTERNS[@]} -eq 0 ]]; then
    echo "Warning: No error patterns defined. Script will run indefinitely unless manually stopped."
fi

# Validate log directory
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: Log directory '$LOG_DIR' does not exist"
    exit 1
fi

# Setup log file
LOG_FILE="${LOG_DIR}/claudelog_$(date +%Y%m%d).log"
echo "Logging to: ${LOG_FILE}"

# Rotate log file if necessary
rotate_log "$LOG_FILE"

# Build Claude command options
CLAUDE_OPTS=""
if [[ "$DANGEROUS_MODE" == true ]]; then
    CLAUDE_OPTS="--dangerously-skip-permissions"
fi
if [[ "$VERBOSE_MODE" == true ]]; then
    CLAUDE_OPTS="$CLAUDE_OPTS --verbose"
fi

# Function to check for error patterns
check_response() {
    local response="$1"
    
    if [[ ${#ERROR_PATTERNS[@]} -eq 0 ]]; then
        return 0
    fi
    
    for pattern in "${ERROR_PATTERNS[@]}"; do
        # Use case-insensitive matching and fixed pattern matching instead of regex
        if [[ "${response,,}" == *"${pattern,,}"* ]]; then
            echo "Error pattern detected: $pattern"
            return 1
        fi
    done
    
    return 0
}

# Function to execute Claude command safely
execute_claude() {
    local message="$1"
    local temp_file
    
    # Create temporary file with proper cleanup
    temp_file=$(mktemp) || {
        echo "Error: Cannot create temporary file"
        return 1
    }
    
    TEMP_FILE="$temp_file"  # Store for cleanup
    
    # Execute Claude command with proper error handling
    if ! claude $CLAUDE_OPTS -c -p "$message" 2>&1 | tee -a "$LOG_FILE" | tee "$temp_file"; then
        echo "Error: Claude command failed"
        rm -f "$temp_file"
        return 1
    fi
    
    # Read the output for error checking
    local response
    response=$(cat "$temp_file")
    rm -f "$temp_file"
    TEMP_FILE=""
    
    # Check for error patterns
    if ! check_response "$response"; then
        return 1
    fi
    
    return 0
}

# Display configuration
echo "Configuration:"
echo "  Dangerous mode: $DANGEROUS_MODE"
echo "  Verbose mode: $VERBOSE_MODE"
echo "  Log directory: $LOG_DIR"
echo "  Wait time: $WAIT_TIME seconds"
echo "  Max log size: $MAX_LOG_SIZE bytes"
echo "  Error patterns: ${ERROR_PATTERNS[*]}"
echo ""

# Warning if not in dangerous mode
if [[ "$DANGEROUS_MODE" != true ]]; then
    echo "WARNING: Running without --dangerous mode may cause the script to hang"
    echo "         when Claude needs to execute tools. Consider using -d option."
    echo ""
fi

# Main loop
echo "Starting automated Claude execution..."
echo "Press Ctrl+C to stop at any time"
echo ""

iteration=0
while true; do
    ((iteration++))
    
    # Rotate log file if necessary
    rotate_log "$LOG_FILE"
    
    echo -e "\n=== Iteration $iteration - $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"
    
    # First claude command
    echo "Executing first command..." | tee -a "$LOG_FILE"
    echo "Message: $MESSAGE1" | tee -a "$LOG_FILE"
    
    if ! execute_claude "$MESSAGE1"; then
        echo "Error detected in first command. Exiting..." | tee -a "$LOG_FILE"
        break
    fi
    
    # Second claude command
    echo -e "\nExecuting second command..." | tee -a "$LOG_FILE"
    echo "Message: $MESSAGE2" | tee -a "$LOG_FILE"
    
    if ! execute_claude "$MESSAGE2"; then
        echo "Error detected in second command. Exiting..." | tee -a "$LOG_FILE"
        break
    fi
    
    # Progress update
    echo -e "\nIteration $iteration completed successfully." | tee -a "$LOG_FILE"
    
    # Ask user for continuation
    echo -e "\nContinue? (Press Ctrl+C to stop, will continue in $WAIT_TIME seconds...)" | tee -a "$LOG_FILE"
    
    # Interruptible sleep
    for ((i=WAIT_TIME; i>0; i--)); do
        sleep 1
        if [[ $i -eq 1 ]]; then
            echo "Continuing..." | tee -a "$LOG_FILE"
        fi
    done
done

echo "Execution completed." | tee -a "$LOG_FILE"