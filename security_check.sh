#!/bin/bash
# security_check.sh - Security validation for claude-auto-runner.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT="./claude-auto-runner.sh"
ISSUES_FOUND=0

echo "==================================="
echo "Security Check for Claude Auto Runner"
echo "==================================="
echo ""

# Function to report issues
report_issue() {
    local severity="$1"
    local message="$2"
    
    case "$severity" in
        "HIGH")
            echo -e "${RED}[HIGH]${NC} $message"
            ((ISSUES_FOUND++))
            ;;
        "MEDIUM")
            echo -e "${YELLOW}[MEDIUM]${NC} $message"
            ((ISSUES_FOUND++))
            ;;
        "LOW")
            echo -e "${BLUE}[LOW]${NC} $message"
            ;;
        "PASS")
            echo -e "${GREEN}[PASS]${NC} $message"
            ;;
    esac
}

# Check 1: File permissions
echo "Checking file permissions..."
perms=$(stat -c %a "$SCRIPT" 2>/dev/null || stat -f %p "$SCRIPT" 2>/dev/null | tail -c 4)
if [[ "$perms" =~ [67][67][67] ]]; then
    report_issue "HIGH" "Script has world-writable permissions ($perms). Should be 755 or more restrictive."
else
    report_issue "PASS" "File permissions are appropriate ($perms)"
fi

# Check 2: Hardcoded credentials
echo -e "\nChecking for hardcoded credentials..."
if grep -E "(password|passwd|pwd|secret|api_key|apikey|token|credential)\\s*=\\s*[\"'][^\"']+[\"']" "$SCRIPT" | grep -v "^#"; then
    report_issue "HIGH" "Potential hardcoded credentials found"
else
    report_issue "PASS" "No hardcoded credentials detected"
fi

# Check 3: Command injection vulnerabilities
echo -e "\nChecking for command injection vulnerabilities..."
dangerous_patterns=(
    'eval\s+'
    'exec\s+'
    '\$\('
    '`'
)
vulnerabilities_found=false
for pattern in "${dangerous_patterns[@]}"; do
    # Exclude safe patterns: comments, mktemp, date, stat, cat with safe file
    if grep -E "$pattern" "$SCRIPT" | grep -v "^#" | grep -v 'mktemp' | grep -v 'date +' | grep -v 'stat -c' | grep -v 'cat "$temp_file"' | grep -v '^\s*response=\$' | grep -v 'echo.*Iteration.*date'; then
        vulnerabilities_found=true
    fi
done
if [[ "$vulnerabilities_found" == true ]]; then
    report_issue "MEDIUM" "Potential command injection points found. Review command execution carefully."
else
    report_issue "PASS" "No obvious command injection vulnerabilities"
fi

# Check 4: Input validation
echo -e "\nChecking input validation..."
if grep -q 'LOG_DIR=' "$SCRIPT" && ! grep -q 'if \[\[ ! -d "$LOG_DIR" \]\]' "$SCRIPT"; then
    report_issue "MEDIUM" "Log directory validation might be missing"
else
    report_issue "PASS" "Input validation appears to be in place"
fi

# Check 5: Temporary file handling
echo -e "\nChecking temporary file handling..."
if grep -q 'mktemp' "$SCRIPT"; then
    if grep -q 'trap.*cleanup' "$SCRIPT" && grep -q 'rm.*TEMP_FILE' "$SCRIPT"; then
        report_issue "PASS" "Temporary files are properly cleaned up"
    else
        report_issue "MEDIUM" "Temporary files might not be cleaned up on exit"
    fi
else
    report_issue "PASS" "No temporary file usage detected"
fi

# Check 6: Dangerous commands
echo -e "\nChecking for dangerous commands..."
dangerous_commands=(
    'rm -rf /'
    'chmod 777'
    'curl.*\|.*sh'
    'wget.*\|.*sh'
)
dangerous_found=false
for cmd in "${dangerous_commands[@]}"; do
    if grep -E "$cmd" "$SCRIPT" | grep -v "^#"; then
        dangerous_found=true
        report_issue "HIGH" "Dangerous command pattern found: $cmd"
    fi
done
if [[ "$dangerous_found" == false ]]; then
    report_issue "PASS" "No dangerous command patterns detected"
fi

# Check 7: Log file security
echo -e "\nChecking log file security..."
if grep -q 'LOG_FILE=' "$SCRIPT"; then
    if grep -q 'umask' "$SCRIPT"; then
        report_issue "PASS" "Log file permissions are controlled"
    else
        report_issue "LOW" "Consider setting umask for log file creation"
    fi
fi

# Check 8: User input sanitization
echo -e "\nChecking user input sanitization..."
if grep -E '\$1|\$2|\$@' "$SCRIPT" | grep -v 'case \$1' | grep -v 'shift' | grep -v '^#'; then
    if grep -q 'printf' "$SCRIPT" || grep -q 'echo.*--' "$SCRIPT"; then
        report_issue "PASS" "User input appears to be handled safely"
    else
        report_issue "LOW" "Ensure all user inputs are properly quoted"
    fi
else
    report_issue "PASS" "Limited direct user input usage"
fi

# Check 9: Error handling
echo -e "\nChecking error handling..."
if grep -q 'set -e' "$SCRIPT" || grep -q 'set -o errexit' "$SCRIPT"; then
    report_issue "MEDIUM" "Script uses 'set -e' which can cause unexpected behavior"
elif grep -q 'if \[' "$SCRIPT" && grep -q 'exit' "$SCRIPT"; then
    report_issue "PASS" "Error handling appears to be implemented"
else
    report_issue "MEDIUM" "Consider improving error handling"
fi

# Check 10: Signal handling
echo -e "\nChecking signal handling..."
if grep -q 'trap' "$SCRIPT"; then
    report_issue "PASS" "Signal handling is implemented"
else
    report_issue "MEDIUM" "No signal handling detected"
fi

# Summary
echo ""
echo "==================================="
echo "Security Check Summary"
echo "==================================="
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}No security issues found!${NC}"
    exit 0
else
    echo -e "${RED}Found $ISSUES_FOUND potential security issues${NC}"
    echo "Please review and address the issues above."
    exit 1
fi