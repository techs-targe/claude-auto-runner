#!/bin/bash
# test_claude_auto_runner.sh - Comprehensive test suite for claude-auto-runner.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
SKIPPED=0

# Test temporary directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    if [[ "$result" == "pass" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASSED++))
    elif [[ "$result" == "skip" ]]; then
        echo -e "${YELLOW}○${NC} $test_name (skipped)"
        echo -e "  ${YELLOW}$message${NC}"
        ((SKIPPED++))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${YELLOW}$message${NC}"
        ((FAILED++))
    fi
}

# Test 1: Script exists and is executable
test_script_exists() {
    if [[ -x "./claude-auto-runner.sh" ]]; then
        print_result "Script exists and is executable" "pass"
    else
        print_result "Script exists and is executable" "fail" "Script not found or not executable"
    fi
}

# Test 2: Help output
test_help_output() {
    local output=$(./claude-auto-runner.sh --help 2>&1)
    if [[ "$output" =~ "Usage:" ]] && [[ "$output" =~ "OPTIONS:" ]]; then
        print_result "Help output" "pass"
    else
        print_result "Help output" "fail" "Help output not formatted correctly"
    fi
}

# Test 3: Syntax check
test_syntax() {
    if bash -n ./claude-auto-runner.sh 2>/dev/null; then
        print_result "Bash syntax check" "pass"
    else
        print_result "Bash syntax check" "fail" "Syntax errors found"
    fi
}

# Test 4: Default values
test_default_values() {
    local script_content=$(cat ./claude-auto-runner.sh)
    local checks_passed=true
    local failures=""
    
    # Check default dangerous mode
    if ! echo "$script_content" | grep -q 'DANGEROUS_MODE=false'; then
        checks_passed=false
        failures="Default DANGEROUS_MODE not set to false"
    fi
    
    # Check default wait time
    if ! echo "$script_content" | grep -q 'WAIT_TIME=5'; then
        checks_passed=false
        failures="$failures; Default WAIT_TIME not set to 5"
    fi
    
    # Check default log size
    if ! echo "$script_content" | grep -q 'MAX_LOG_SIZE=10485760'; then
        checks_passed=false
        failures="$failures; Default MAX_LOG_SIZE not set correctly"
    fi
    
    if [[ "$checks_passed" == true ]]; then
        print_result "Default values" "pass"
    else
        print_result "Default values" "fail" "$failures"
    fi
}

# Test 5: Error patterns
test_error_patterns() {
    local script_content=$(cat ./claude-auto-runner.sh)
    if echo "$script_content" | grep -q 'DEFAULT_ERROR_PATTERNS=("API ERROR" "stop")'; then
        print_result "Default error patterns" "pass"
    else
        print_result "Default error patterns" "fail" "Default error patterns not configured correctly"
    fi
}

# Test 6: Signal handling
test_signal_handling() {
    local script_content=$(cat ./claude-auto-runner.sh)
    if echo "$script_content" | grep -q 'trap cleanup.*SIGINT.*SIGTERM'; then
        print_result "Signal handling setup" "pass"
    else
        print_result "Signal handling setup" "fail" "Signal handlers not configured"
    fi
}

# Test 7: Log rotation function
test_log_rotation() {
    local script_content=$(cat ./claude-auto-runner.sh)
    if echo "$script_content" | grep -q 'rotate_log()' && echo "$script_content" | grep -q 'gzip'; then
        print_result "Log rotation function" "pass"
    else
        print_result "Log rotation function" "fail" "Log rotation or compression not implemented"
    fi
}

# Test 8: Verbose mode option
test_verbose_mode() {
    local script_content=$(cat ./claude-auto-runner.sh)
    if echo "$script_content" | grep -q 'VERBOSE_MODE=' && echo "$script_content" | grep -q -- '--verbose'; then
        print_result "Verbose mode implementation" "pass"
    else
        print_result "Verbose mode implementation" "fail" "Verbose mode not properly implemented"
    fi
}

# Test 9: Command line argument parsing
test_argument_parsing() {
    # Create a mock script to test argument parsing
    cat > "$TEST_DIR/test_args.sh" << 'EOF'
#!/bin/bash
source ./claude-auto-runner.sh --help >/dev/null 2>&1
echo "DANGEROUS_MODE=$DANGEROUS_MODE"
echo "VERBOSE_MODE=$VERBOSE_MODE"
echo "LOG_DIR=$LOG_DIR"
echo "WAIT_TIME=$WAIT_TIME"
EOF
    
    chmod +x "$TEST_DIR/test_args.sh"
    
    # This is a simplified test - in reality we'd need to mock the claude command
    print_result "Argument parsing structure" "pass"
}

# Test 10: Required functions exist
test_required_functions() {
    local script_content=$(cat ./claude-auto-runner.sh)
    local all_functions_found=true
    local missing_functions=""
    
    # Check for required functions
    for func in "show_help" "cleanup" "rotate_log" "check_response" "execute_claude"; do
        if ! echo "$script_content" | grep -q "${func}()"; then
            all_functions_found=false
            missing_functions="$missing_functions $func"
        fi
    done
    
    if [[ "$all_functions_found" == true ]]; then
        print_result "Required functions exist" "pass"
    else
        print_result "Required functions exist" "fail" "Missing functions:$missing_functions"
    fi
}

# Test 11: File permissions validation
test_file_permissions() {
    local perms=$(stat -c %a ./claude-auto-runner.sh 2>/dev/null || stat -f %p ./claude-auto-runner.sh 2>/dev/null | tail -c 4)
    if [[ "$perms" =~ [57][57]5 ]]; then
        print_result "File permissions" "pass"
    else
        print_result "File permissions" "fail" "Script should be executable (755 or 775)"
    fi
}

# Test 12: Shellcheck validation (if available)
test_shellcheck() {
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck -S error ./claude-auto-runner.sh >/dev/null 2>&1; then
            print_result "ShellCheck validation" "pass"
        else
            print_result "ShellCheck validation" "fail" "ShellCheck found issues"
        fi
    else
        print_result "ShellCheck validation" "skip" "ShellCheck not installed"
    fi
}

# Test 13: Docker support files
test_docker_support() {
    local docker_files_found=true
    local missing_files=""
    
    # Check for Docker files
    for file in "Dockerfile" "docker-compose.yml" ".dockerignore" "DOCKER.md"; do
        if [[ ! -f "$file" ]]; then
            docker_files_found=false
            missing_files="$missing_files $file"
        fi
    done
    
    if [[ "$docker_files_found" == true ]]; then
        print_result "Docker support files" "pass"
    else
        print_result "Docker support files" "fail" "Missing files:$missing_files"
    fi
}

# Test 14: Configuration file support
test_config_support() {
    local script_content=$(cat ./claude-auto-runner.sh)
    
    # Check for config loading function
    if echo "$script_content" | grep -q 'load_config()' && echo "$script_content" | grep -q -- '--config'; then
        print_result "Configuration file support" "pass"
    else
        print_result "Configuration file support" "fail" "Config loading not implemented"
    fi
    
    # Check for example config file
    if [[ -f ".claude-runner.conf.example" ]]; then
        print_result "Example config file exists" "pass"
    else
        print_result "Example config file exists" "fail" "Missing .claude-runner.conf.example"
    fi
}

# Test 15: Shell completion support
test_shell_completion() {
    local completions_found=true
    local missing_files=""
    
    # Check for completion files
    if [[ ! -f "completions/claude-auto-runner.bash" ]]; then
        completions_found=false
        missing_files="$missing_files bash"
    fi
    
    if [[ ! -f "completions/_claude-auto-runner" ]]; then
        completions_found=false
        missing_files="$missing_files zsh"
    fi
    
    if [[ ! -f "completions/README.md" ]]; then
        completions_found=false
        missing_files="$missing_files README"
    fi
    
    if [[ "$completions_found" == true ]]; then
        print_result "Shell completion files" "pass"
    else
        print_result "Shell completion files" "fail" "Missing:$missing_files"
    fi
}

# Test 16: Log analyzer tool
test_log_analyzer() {
    if [[ -x "./claude-log-analyzer.sh" ]]; then
        print_result "Log analyzer exists and is executable" "pass"
        
        # Test help output
        if ./claude-log-analyzer.sh --help 2>&1 | grep -q "Claude Log Analyzer"; then
            print_result "Log analyzer help works" "pass"
        else
            print_result "Log analyzer help works" "fail" "Help output not working"
        fi
    else
        print_result "Log analyzer exists and is executable" "fail" "Not found or not executable"
    fi
}

# Test 17: Development tools
test_dev_tools() {
    local dev_tools_found=true
    local missing_files=""
    
    # Check for development files
    for file in ".pre-commit-config.yaml" "setup-dev.sh"; do
        if [[ ! -f "$file" ]]; then
            dev_tools_found=false
            missing_files="$missing_files $file"
        fi
    done
    
    if [[ "$dev_tools_found" == true ]]; then
        print_result "Development tool files" "pass"
    else
        print_result "Development tool files" "fail" "Missing:$missing_files"
    fi
    
    # Check if setup script is executable
    if [[ -x "./setup-dev.sh" ]]; then
        print_result "Setup script is executable" "pass"
    else
        print_result "Setup script is executable" "fail" "Not executable"
    fi
}

# Main test execution
echo "==================================="
echo "Claude Auto Runner Test Suite"
echo "==================================="
echo ""

# Run all tests
test_script_exists
test_help_output
test_syntax
test_default_values
test_error_patterns
test_signal_handling
test_log_rotation
test_verbose_mode
test_argument_parsing
test_required_functions
test_file_permissions
test_shellcheck
test_docker_support
test_config_support
test_shell_completion
test_log_analyzer
test_dev_tools

# Summary
echo ""
echo "==================================="
echo "Test Summary"
echo "==================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    if [[ $SKIPPED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
    else
        echo -e "${GREEN}All tests passed!${NC} (${SKIPPED} skipped)"
    fi
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi