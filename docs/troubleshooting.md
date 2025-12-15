# Troubleshooting Guide

Common issues and solutions for the Auto-Init system.

---

## Installation Issues

### Command Not Found

**Symptoms:** `/init-claude` not recognized

**Causes:**
- Files not installed correctly
- Claude Code not restarted
- Command files missing

**Solutions:**
```powershell
# 1. Verify installation
ls ~/.claude/commands/init-claude.*

# 2. Restart Claude Code CLI

# 3. Reinstall if needed
Copy-Item -Path "./claude-config/.claude" -Destination "$env:USERPROFILE\.claude" -Recurse -Force
```

---

## Detection Issues

### Framework Not Detected

**Symptoms:** Shows "unknown" framework incorrectly

**Solutions:**
```powershell
# Debug scanner output
powershell.exe -File ~/.claude/scripts/auto-init/scanner.ps1

# Check for framework indicators:
# - package.json (Node.js projects)
# - requirements.txt (Python projects)
# - go.mod (Go projects)
```

---

## Execution Issues

### PowerShell Permission Denied

**Symptoms:** "Execution of scripts is disabled"

**Solutions:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Template Not Found

**Symptoms:** "Template not found: framework.template.md"

**Solutions:**
```powershell
# Verify templates exist
ls ~/.claude/templates/auto-init/

# Reinstall if missing
```

---

## Generation Issues

### Placeholders Not Replaced

**Symptoms:** `{{VAR}}` in generated file

**Solutions:**
- Check variable defined in `selector.ps1`
- Verify exact name match (case-sensitive)
- Check for typos

### Conditionals Not Working

**Symptoms:** Conditional content shows incorrectly

**Solutions:**
- Ensure boolean values (`$true`/`$false`, not strings)
- Check syntax: `{{#IF VAR}}...{{/IF}}`

---

## Need More Help?

- **GitHub Issues:** https://github.com/patichu0101/claude-config/issues
- **Documentation:** Full docs in `docs/` directory
- **Examples:** Working examples in `examples/` directory
