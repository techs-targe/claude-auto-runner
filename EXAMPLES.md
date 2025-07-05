# Claude Auto Runner - Example Usage Scenarios

This document provides practical examples and use cases for the Claude Auto Runner script.

## Table of Contents
- [Basic Usage](#basic-usage)
- [Development Workflows](#development-workflows)
- [Data Processing](#data-processing)
- [Code Review and Refactoring](#code-review-and-refactoring)
- [Documentation Generation](#documentation-generation)
- [Testing Automation](#testing-automation)
- [Best Practices](#best-practices)

## Basic Usage

### Simple Task Execution
```bash
# Run with default settings
./claude-auto-runner.sh --dangerous
```

### Custom Messages for Specific Tasks
```bash
# Code implementation task
./claude-auto-runner.sh --dangerous \
  -m1 "Implement the user authentication feature" \
  -m2 "Have you added tests and documentation for the auth feature?"

# Bug fixing workflow
./claude-auto-runner.sh --dangerous \
  -m1 "Find and fix the next bug in the issue tracker" \
  -m2 "Did you verify the fix and add regression tests?"
```

## Development Workflows

### Feature Development Queue
```bash
# Set up a feature development workflow
./claude-auto-runner.sh --dangerous --verbose \
  -m1 "next - implement the next feature from the roadmap" \
  -m2 "Have you completed all tests, documentation, and code review checklist items?"
```

### Continuous Code Improvement
```bash
# Automated code quality improvements
./claude-auto-runner.sh --dangerous \
  -m1 "Find and improve the next code smell or performance issue" \
  -m2 "Did you benchmark the improvements and ensure no regressions?"
```

## Data Processing

### Batch Data Processing
```bash
# Process multiple data files
./claude-auto-runner.sh --dangerous --log-dir ./processing_logs \
  -m1 "Process the next data file in the queue folder" \
  -m2 "Has the data been validated and output files generated correctly?"
```

### Data Migration Tasks
```bash
# Database migration workflow
./claude-auto-runner.sh --dangerous \
  -m1 "Execute the next database migration script" \
  -m2 "Have you verified data integrity and created rollback procedures?"
```

## Code Review and Refactoring

### Automated Code Review
```bash
# Review pull requests
./claude-auto-runner.sh --dangerous --wait 10 \
  -m1 "Review the next pull request and provide detailed feedback" \
  -m2 "Have you checked for security issues, performance impacts, and test coverage?"
```

### Refactoring Legacy Code
```bash
# Incremental refactoring
./claude-auto-runner.sh --dangerous \
  -m1 "Refactor the next legacy module to use modern patterns" \
  -m2 "Are all tests still passing and is the behavior unchanged?"
```

## Documentation Generation

### API Documentation
```bash
# Generate API docs
./claude-auto-runner.sh --dangerous \
  -m1 "Document the next undocumented API endpoint" \
  -m2 "Is the documentation complete with examples and error cases?"
```

### Code Comments and README Updates
```bash
# Improve code documentation
./claude-auto-runner.sh --dangerous \
  -m1 "Add comprehensive comments to the next complex function" \
  -m2 "Are the comments clear and do they explain the why, not just the what?"
```

## Testing Automation

### Test Suite Development
```bash
# Create missing tests
./claude-auto-runner.sh --dangerous \
  -m1 "Write tests for the next untested component" \
  -m2 "Do the tests cover edge cases and achieve >80% coverage?"
```

### Test Failure Investigation
```bash
# Debug failing tests
./claude-auto-runner.sh --dangerous --verbose \
  -m1 "Investigate and fix the next failing test" \
  -m2 "Have you identified the root cause and prevented similar issues?"
```

## Best Practices

### 1. Use Descriptive Error Patterns
```bash
# Custom error patterns for your workflow
./claude-auto-runner.sh --dangerous \
  --clear-errors \
  --error-pattern "CRITICAL" \
  --error-pattern "FAILED" \
  --error-pattern "BLOCKED" \
  -m1 "Continue with the deployment process" \
  -m2 "Are all deployment checks passing?"
```

### 2. Organized Logging
```bash
# Separate logs by task type
./claude-auto-runner.sh --dangerous \
  --log-dir ./logs/features \
  --max-log-size 104857600 \
  -m1 "Implement the next feature" \
  -m2 "Is the feature complete and tested?"
```

### 3. Verbose Mode for Debugging
```bash
# Debug complex tasks
./claude-auto-runner.sh --dangerous --verbose \
  -m1 "Debug the performance issue in the data pipeline" \
  -m2 "Have you identified the bottleneck and implemented a fix?"
```

### 4. Appropriate Wait Times
```bash
# Longer wait for resource-intensive tasks
./claude-auto-runner.sh --dangerous \
  --wait 30 \
  -m1 "Run the full test suite and generate coverage report" \
  -m2 "Are all tests passing with adequate coverage?"
```

### 5. Task Queue Pattern
Create a `tasks.md` file with your task queue:
```markdown
## Task Queue
- [ ] Implement user authentication
- [ ] Add password reset functionality
- [ ] Create user profile page
- [ ] Add email notifications
```

Then use:
```bash
./claude-auto-runner.sh --dangerous \
  -m1 "Complete the next task from tasks.md and mark it as done" \
  -m2 "Is the task fully implemented with tests and documentation?"
```

## Advanced Patterns

### Conditional Workflows
```bash
# Different actions based on time
if [[ $(date +%H) -lt 12 ]]; then
  MESSAGE1="Focus on bug fixes from the morning bug report"
else
  MESSAGE1="Work on new feature development"
fi

./claude-auto-runner.sh --dangerous \
  -m1 "$MESSAGE1" \
  -m2 "Have you completed the task with all quality checks?"
```

### Integration with CI/CD
```bash
# Post-deployment validation
./claude-auto-runner.sh --dangerous \
  --error-pattern "DEPLOYMENT_FAILED" \
  -m1 "Verify the deployment and run smoke tests" \
  -m2 "Are all services healthy and responding correctly?"
```

## Safety Considerations

1. **Always use `--dangerous` flag** for automated workflows to prevent hanging on tool usage
2. **Set appropriate error patterns** to stop execution when issues occur
3. **Use separate log directories** for different types of tasks
4. **Monitor log file sizes** and set appropriate limits
5. **Test your messages** in a safe environment first

## Troubleshooting Common Issues

### Script Hangs Without Progress
```bash
# Add --dangerous flag
./claude-auto-runner.sh --dangerous -m1 "Your task"
```

### Need More Context in Logs
```bash
# Enable verbose mode
./claude-auto-runner.sh --dangerous --verbose -m1 "Complex debugging task"
```

### Log Files Growing Too Large
```bash
# Set smaller rotation size (5MB)
./claude-auto-runner.sh --dangerous --max-log-size 5242880
```

Remember to always monitor your automated workflows and adjust parameters based on your specific needs!