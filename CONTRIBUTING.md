# Contributing to Claude Auto Runner

Thank you for your interest in contributing to Claude Auto Runner! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully
- Put the project's best interests first

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone git@github.com:YOUR_USERNAME/claude-auto-runner.git
   cd claude-auto-runner
   ```
3. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Types of Contributions

- **Bug Fixes**: Fix issues reported in GitHub Issues
- **Features**: Add new functionality to the script
- **Documentation**: Improve or expand documentation
- **Tests**: Add or improve test coverage
- **Examples**: Add practical examples to EXAMPLES.md

### Before Starting

1. Check existing issues and pull requests to avoid duplicating work
2. For major changes, open an issue first to discuss your proposal
3. Ensure your idea aligns with the project's goals

## Development Guidelines

### Code Style

- Use consistent indentation (4 spaces for bash)
- Follow bash best practices:
  - Quote variables: `"$variable"`
  - Use `[[ ]]` instead of `[ ]` for conditionals
  - Use meaningful variable names
  - Add comments for complex logic

### Script Standards

- Always use `#!/bin/bash` shebang
- Set appropriate error handling
- Validate user inputs
- Handle edge cases gracefully
- Maintain backward compatibility

### Security Considerations

- Never hardcode credentials
- Validate all user inputs
- Use secure file permissions
- Handle temporary files safely
- Follow the security patterns in the existing code

## Testing

### Running Tests

1. Run the test suite:
   ```bash
   ./test_claude_auto_runner.sh
   ```

2. Run security checks:
   ```bash
   ./security_check.sh
   ```

3. Test your changes manually:
   ```bash
   # Test help output
   ./claude-auto-runner.sh --help
   
   # Test with various options
   ./claude-auto-runner.sh --dangerous --verbose
   ```

### Adding Tests

- Add new test cases to `test_claude_auto_runner.sh`
- Ensure new features have corresponding tests
- Test both success and failure scenarios
- Document what your tests verify

## Pull Request Process

1. **Update Documentation**:
   - Update README.md if you've added features
   - Add examples to EXAMPLES.md if applicable
   - Update CHANGELOG.md following the existing format

2. **Ensure Quality**:
   - All tests must pass
   - Security check must pass
   - No syntax errors (check with `bash -n`)
   - Code follows project standards

3. **Submit PR**:
   - Write a clear PR title and description
   - Reference any related issues
   - Include examples of your changes in action
   - Be responsive to review feedback

4. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Test improvement
   
   ## Testing
   - [ ] Test suite passes
   - [ ] Security check passes
   - [ ] Manual testing completed
   
   ## Checklist
   - [ ] Documentation updated
   - [ ] CHANGELOG.md updated
   - [ ] Code follows project standards
   ```

## Reporting Issues

### Bug Reports

When reporting bugs, include:

1. **Environment**:
   - OS and version
   - Bash version (`bash --version`)
   - Claude CLI version

2. **Steps to Reproduce**:
   - Exact commands used
   - Configuration/options used
   - Expected vs actual behavior

3. **Logs**:
   - Relevant error messages
   - Log file excerpts if applicable

### Feature Requests

For feature requests:

1. Describe the problem you're trying to solve
2. Explain your proposed solution
3. Provide examples of how it would be used
4. Consider backward compatibility

## Version Numbering

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Questions?

If you have questions:

1. Check existing documentation
2. Search closed issues
3. Open a new issue with the "question" label

Thank you for contributing to Claude Auto Runner! 🚀