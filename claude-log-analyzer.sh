#!/bin/bash
# claude-log-analyzer.sh - Log analysis tool for Claude Auto Runner
# Version: 1.0.0

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
LOG_DIR="."
PATTERN=""
STATS_ONLY=false
ERRORS_ONLY=false
VERBOSE=false
DATE_FILTER=""

# Function to display help
show_help() {
    cat << EOF
Claude Log Analyzer v1.0.0

Usage: $0 [OPTIONS]

Analyze Claude Auto Runner log files for patterns, errors, and statistics.

OPTIONS:
    -h, --help              Show this help message and exit
    -l, --log-dir DIR       Log directory to analyze (default: current directory)
    -p, --pattern PATTERN   Search for specific pattern in logs
    -s, --stats            Show statistics only
    -e, --errors           Show errors only
    -v, --verbose          Verbose output
    -d, --date DATE        Filter by date (YYYYMMDD format)
    --today                Analyze today's logs only
    --yesterday            Analyze yesterday's logs only

EXAMPLES:
    # Analyze all logs in current directory
    $0

    # Show statistics for today's logs
    $0 --today --stats

    # Search for errors in specific directory
    $0 --log-dir /var/log/claude --errors

    # Search for specific pattern
    $0 --pattern "API ERROR" --verbose

    # Analyze logs from specific date
    $0 --date 20250105
EOF
}

# Function to analyze log file
analyze_log() {
    local log_file="$1"
    local total_lines=0
    local iteration_count=0
    local error_count=0
    local first_timestamp=""
    local last_timestamp=""
    local errors=()
    
    if [[ ! -f "$log_file" ]]; then
        return
    fi
    
    echo -e "\n${BLUE}Analyzing: $log_file${NC}"
    
    # Count lines and iterations
    total_lines=$(wc -l < "$log_file")
    iteration_count=$(grep -c "=== Iteration" "$log_file" 2>/dev/null || echo 0)
    
    # Get timestamps
    first_timestamp=$(grep -m1 "=== Iteration.*-" "$log_file" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' | head -1)
    last_timestamp=$(grep "=== Iteration.*-" "$log_file" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' | tail -1)
    
    # Count errors
    error_count=$(grep -cE "(Error:|ERROR|Error detected|error pattern detected)" "$log_file" 2>/dev/null || echo 0)
    
    # Find specific errors if requested
    if [[ "$ERRORS_ONLY" == true ]] || [[ "$VERBOSE" == true ]]; then
        while IFS= read -r line; do
            errors+=("$line")
        done < <(grep -nE "(Error:|ERROR|Error detected|error pattern detected)" "$log_file" 2>/dev/null)
    fi
    
    # Search for pattern if specified
    if [[ -n "$PATTERN" ]]; then
        echo -e "${CYAN}Pattern matches for '$PATTERN':${NC}"
        grep -n "$PATTERN" "$log_file" | head -20
        local pattern_count=$(grep -c "$PATTERN" "$log_file" 2>/dev/null || echo 0)
        echo -e "${CYAN}Total matches: $pattern_count${NC}"
    fi
    
    # Show statistics
    if [[ "$STATS_ONLY" == true ]] || [[ -z "$PATTERN" && "$ERRORS_ONLY" != true ]]; then
        echo -e "${GREEN}Statistics:${NC}"
        echo "  Total lines: $total_lines"
        echo "  Iterations: $iteration_count"
        echo "  Errors found: $error_count"
        [[ -n "$first_timestamp" ]] && echo "  First run: $first_timestamp"
        [[ -n "$last_timestamp" ]] && echo "  Last run: $last_timestamp"
        
        # Calculate runtime if timestamps available
        if [[ -n "$first_timestamp" && -n "$last_timestamp" ]]; then
            local start_epoch=$(date -d "$first_timestamp" +%s 2>/dev/null)
            local end_epoch=$(date -d "$last_timestamp" +%s 2>/dev/null)
            if [[ -n "$start_epoch" && -n "$end_epoch" ]]; then
                local duration=$((end_epoch - start_epoch))
                local hours=$((duration / 3600))
                local minutes=$(((duration % 3600) / 60))
                echo "  Total runtime: ${hours}h ${minutes}m"
            fi
        fi
    fi
    
    # Show errors if requested
    if [[ "$ERRORS_ONLY" == true ]] || [[ "$VERBOSE" == true && ${#errors[@]} -gt 0 ]]; then
        echo -e "\n${RED}Errors found:${NC}"
        for error in "${errors[@]}"; do
            echo "  $error"
        done | head -20
        if [[ ${#errors[@]} -gt 20 ]]; then
            echo "  ... and $((${#errors[@]} - 20)) more errors"
        fi
    fi
}

# Function to analyze all logs
analyze_all_logs() {
    local log_pattern="claudelog_*.log"
    
    # Apply date filter if specified
    if [[ -n "$DATE_FILTER" ]]; then
        log_pattern="claudelog_${DATE_FILTER}.log"
    fi
    
    # Find all matching log files
    local log_files=()
    while IFS= read -r -d '' file; do
        log_files+=("$file")
    done < <(find "$LOG_DIR" -name "$log_pattern" -type f -print0 2>/dev/null | sort -z)
    
    if [[ ${#log_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No log files found matching pattern: $log_pattern${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Found ${#log_files[@]} log file(s) to analyze${NC}"
    
    # Analyze each log file
    for log_file in "${log_files[@]}"; do
        analyze_log "$log_file"
    done
    
    # Show summary if multiple files
    if [[ ${#log_files[@]} -gt 1 ]]; then
        echo -e "\n${BLUE}=== Summary ===${NC}"
        local total_iterations=0
        local total_errors=0
        
        for log_file in "${log_files[@]}"; do
            local iterations=$(grep -c "=== Iteration" "$log_file" 2>/dev/null || echo 0)
            local errors=$(grep -cE "(Error:|ERROR|Error detected|error pattern detected)" "$log_file" 2>/dev/null || echo 0)
            total_iterations=$((total_iterations + iterations))
            total_errors=$((total_errors + errors))
        done
        
        echo "Total files analyzed: ${#log_files[@]}"
        echo "Total iterations: $total_iterations"
        echo "Total errors: $total_errors"
        
        if [[ $total_iterations -gt 0 ]]; then
            local error_rate=$(awk "BEGIN {printf \"%.2f\", ($total_errors / $total_iterations) * 100}")
            echo "Error rate: ${error_rate}%"
        fi
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--log-dir)
            if [[ -z "$2" ]]; then
                echo "Error: --log-dir requires a directory path"
                exit 1
            fi
            LOG_DIR="$2"
            shift 2
            ;;
        -p|--pattern)
            if [[ -z "$2" ]]; then
                echo "Error: --pattern requires a search pattern"
                exit 1
            fi
            PATTERN="$2"
            shift 2
            ;;
        -s|--stats)
            STATS_ONLY=true
            shift
            ;;
        -e|--errors)
            ERRORS_ONLY=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--date)
            if [[ -z "$2" || ! "$2" =~ ^[0-9]{8}$ ]]; then
                echo "Error: --date requires YYYYMMDD format"
                exit 1
            fi
            DATE_FILTER="$2"
            shift 2
            ;;
        --today)
            DATE_FILTER=$(date +%Y%m%d)
            shift
            ;;
        --yesterday)
            DATE_FILTER=$(date -d "yesterday" +%Y%m%d 2>/dev/null || date -v-1d +%Y%m%d)
            shift
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
    echo -e "${RED}Error: Log directory '$LOG_DIR' does not exist${NC}"
    exit 1
fi

# Main execution
echo -e "${BLUE}Claude Log Analyzer v1.0.0${NC}"
echo -e "${BLUE}=========================${NC}"
echo "Log directory: $LOG_DIR"
[[ -n "$DATE_FILTER" ]] && echo "Date filter: $DATE_FILTER"
[[ -n "$PATTERN" ]] && echo "Search pattern: $PATTERN"
[[ "$STATS_ONLY" == true ]] && echo "Mode: Statistics only"
[[ "$ERRORS_ONLY" == true ]] && echo "Mode: Errors only"
[[ "$VERBOSE" == true ]] && echo "Mode: Verbose"

# Analyze logs
analyze_all_logs

echo -e "\n${GREEN}Analysis complete!${NC}"