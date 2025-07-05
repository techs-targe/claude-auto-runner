# Troubleshooting Guide

This guide helps you resolve common issues with Claude Auto Runner.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Runtime Errors](#runtime-errors)
- [Performance Issues](#performance-issues)
- [Log File Issues](#log-file-issues)
- [Claude CLI Issues](#claude-cli-issues)
- [Common Error Messages](#common-error-messages)
- [Debugging Tips](#debugging-tips)

## Installation Issues

### Permission Denied

**Problem**: `bash: ./claude-auto-runner.sh: Permission denied`

**Solution**:
```bash
chmod +x claude-auto-runner.sh
```

### Command Not Found (after installation)

**Problem**: `command not found: claude-auto-runner.sh`

**Solution**:
1. Check if installed: `ls -la /usr/local/bin/claude-auto-runner.sh`
2. Install using make: `make install`
3. Or add to PATH: `export PATH=$PATH:/path/to/script/directory`

## Runtime Errors

### Script Hangs Without Progress

**Problem**: Script appears to freeze, no output

**Cause**: Not using `--dangerous` flag when Claude needs to use tools

**Solution**:
```bash
./claude-auto-runner.sh --dangerous
```

### "Claude command not found"

**Problem**: `Error: 'claude' command not found. Please install Claude CLI.`

**Solution**:
1. Install Claude CLI from https://claude.ai/download
2. Verify installation: `which claude`
3. Ensure claude is in PATH

### "API ERROR" Immediately Stops Script

**Problem**: Script stops with API ERROR on first run

**Possible Causes**:
- Not authenticated with Claude CLI
- Network connectivity issues
- Rate limiting

**Solutions**:
1. Authenticate: `claude auth login`
2. Check network: `ping api.anthropic.com`
3. Wait and retry if rate limited

### Log Directory Issues

**Problem**: `Error: No write permissions for log directory`

**Solution**:
1. Check permissions: `ls -ld /path/to/log/dir`
2. Fix permissions: `chmod 755 /path/to/log/dir`
3. Or use different directory: `--log-dir ~/logs`

## Performance Issues

### Script Running Too Slowly

**Problem**: Long delays between iterations

**Solutions**:
1. Reduce wait time: `--wait 2`
2. Check system resources: `top` or `htop`
3. Use simpler messages to reduce processing time

### Log Files Growing Too Large

**Problem**: Disk space filling up with logs

**Solutions**:
1. Set smaller rotation size: `--max-log-size 5242880` (5MB)
2. Clean old logs: `make clean`
3. Manually remove old logs: `rm claudelog_*.log.*.gz`

## Log File Issues

### Cannot Create Log File

**Problem**: `Error: Cannot create log directory`

**Solutions**:
1. Check parent directory permissions
2. Use home directory: `--log-dir ~/claude-logs`
3. Run with sudo (not recommended): `sudo ./claude-auto-runner.sh`

### Log Rotation Not Working

**Problem**: Log files exceed max size without rotating

**Possible Causes**:
- No write permissions in log directory
- `gzip` command not available

**Solutions**:
1. Check gzip: `which gzip`
2. Install gzip if missing: `apt-get install gzip` or `brew install gzip`
3. Check directory permissions

## Claude CLI Issues

### Authentication Errors

**Problem**: Claude commands fail with auth errors

**Solution**:
```bash
# Re-authenticate
claude auth logout
claude auth login
```

### Rate Limiting

**Problem**: Getting rate limit errors

**Solutions**:
1. Increase wait time: `--wait 30`
2. Add retry logic (already built-in with 3 retries)
3. Consider upgrading Claude plan

### Network Timeouts

**Problem**: Claude commands timing out

**Solutions**:
1. Check internet connection
2. Try with verbose mode to see details: `--verbose`
3. Check proxy settings if behind corporate firewall

## Common Error Messages

### "Error pattern detected: stop"

**Meaning**: The script detected "stop" in Claude's response

**This is intentional if**:
- You asked Claude to say "stop" when done
- Claude encountered an unsolvable problem

**To continue**: Remove "stop" from error patterns: `--clear-errors`

### "Unknown option"

**Problem**: `Unknown option: --some-flag`

**Solution**: Check spelling and available options: `./claude-auto-runner.sh --help`

### "requires a numeric value"

**Problem**: Invalid input for numeric options

**Solution**: Use numbers only: `--wait 5` not `--wait five`

## Debugging Tips

### Enable Verbose Mode

See Claude's thinking process:
```bash
./claude-auto-runner.sh --dangerous --verbose
```

### Check Logs in Real-Time

Monitor log file while running:
```bash
tail -f claudelog_$(date +%Y%m%d).log
```

### Test with Simple Messages

Debug with basic commands:
```bash
./claude-auto-runner.sh --dangerous \
  -m1 "echo 'test'" \
  -m2 "echo 'done' && echo 'stop'"
```

### Run Security Check

Ensure no security issues:
```bash
./security_check.sh
```

### Validate Script Syntax

Check for syntax errors:
```bash
bash -n claude-auto-runner.sh
```

## Getting Help

If you still have issues:

1. **Check existing issues**: https://github.com/techs-targe/claude-auto-runner/issues
2. **Enable verbose mode** and capture full output
3. **Create detailed bug report** with:
   - OS and bash version
   - Exact command used
   - Full error output
   - Log file excerpts

## Quick Fixes Checklist

- [ ] Using `--dangerous` flag?
- [ ] Claude CLI installed and authenticated?
- [ ] Script has execute permissions?
- [ ] Log directory exists and is writable?
- [ ] No typos in command flags?
- [ ] Wait time reasonable (1-3600)?
- [ ] Network connection working?
- [ ] Sufficient disk space for logs?