# Getting Started with Auto-Init

Welcome to the Claude Code Auto-Init system! This guide will help you set up and start using `/init-claude` to generate project-specific CLAUDE.md files.

---

## Quick Start (5 minutes)

### 1. Install the System

**Option A: Copy to User Directory (Recommended)**

```powershell
# Copy the entire .claude directory to your user home
Copy-Item -Path "./claude-config/.claude" -Destination "$env:USERPROFILE\.claude" -Recurse -Force

# Restart Claude Code CLI to load the configuration
```

**Option B: Project-Level Installation**

```powershell
# Copy to a specific project
cd C:\path\to\your\project
Copy-Item -Path "./claude-config/.claude" -Destination "./.claude" -Recurse -Force
```

### 2. Verify Installation

```powershell
# Check that files are installed
ls ~/.claude/commands/init-claude.*
ls ~/.claude/scripts/auto-init/
ls ~/.claude/templates/auto-init/

# You should see:
# - commands/init-claude.md
# - commands/init-claude.js
# - scripts/auto-init/ (8 PowerShell scripts)
# - templates/auto-init/ (7 templates + README)
```

### 3. Run Your First Auto-Init

```powershell
# Navigate to a project
cd C:\Users\YourName\Projects\my-nextjs-app

# Run the command in Claude Code CLI
/init-claude

# Follow the prompts:
# 1. Confirm detected framework
# 2. Choose code style (functional/OOP)
# 3. Review generated files
```

### 4. Review Generated Files

```powershell
# Check what was created
cat CLAUDE.md        # Project-specific memory
cat AGENT.md         # Optional agent guide

# Check backup (if files existed before)
ls .backup/          # Timestamped backups
```

---

## System Requirements

- **OS:** Windows 10/11 (PowerShell 5.1+) or Windows with PowerShell Core 7+
- **Node.js:** 18+ (for command handler)
- **Claude Code:** Latest version
- **Git:** (Optional) For version control of generated files

---

## Supported Frameworks

| Framework | Auto-Detection | Template Features |
|-----------|----------------|-------------------|
| **Next.js 14+** | package.json → "next" | App Router, Server Components, Route Handlers |
| **React + Vite** | package.json → "vite" + "react" | Hooks, Component patterns, HMR |
| **FastAPI** | requirements.txt → "fastapi" | Async/await, Pydantic v2, Type hints |
| **Django** | requirements.txt → "django" | ORM patterns, Migrations, Admin |
| **Go** | go.mod file present | Modules, Goroutines, Error handling |
| **Generic** | No framework detected | Universal fallback template |

---

## Usage Examples

### Example 1: Next.js Project

```powershell
# Navigate to Next.js project
cd C:\Projects\my-nextjs-14-app

# Run auto-init
/init-claude

# System detects:
#   ✓ Framework: Next.js 14.2.5
#   ✓ Router: App Router
#   ✓ Package Manager: npm
#   ✓ Test Framework: jest

# Generated CLAUDE.md includes:
#   - Server Components best practices
#   - App Router file structure
#   - Route Handlers patterns
#   - Project dependencies
```

### Example 2: FastAPI Project

```powershell
# Navigate to FastAPI project
cd C:\Projects\my-fastapi-api

# Run auto-init
/init-claude

# System detects:
#   ✓ Framework: FastAPI 0.104.0
#   ✓ Package Manager: uv
#   ✓ Test Framework: pytest
#   ✓ Python: 3.13

# Generated CLAUDE.md includes:
#   - Async/await patterns
#   - Pydantic v2 validation
#   - Type hints best practices
#   - FastAPI-specific patterns
```

### Example 3: Generic Project

```powershell
# Navigate to any project (no framework)
cd C:\Projects\my-custom-app

# Run auto-init
/init-claude

# System uses generic template:
#   - Project structure documentation
#   - General best practices
#   - Customizable sections
```

---

## Configuration

### Customizing Templates

Templates are located in `.claude/templates/auto-init/`. Edit them to customize generated output:

```powershell
# Edit Next.js template
code ~/.claude/templates/auto-init/nextjs.template.md

# Add custom sections, placeholders, or patterns
```

See [templates.md](./templates.md) for full customization guide.

### Adding Custom Placeholders

Edit `.claude/scripts/auto-init/selector.ps1` to add custom variables:

```powershell
# Add to $variables hash (around line 79)
$variables = @{
    # ... existing variables ...
    MY_CUSTOM_SETTING = "value"
}
```

Use in templates:
```markdown
## Custom Section
- Setting: {{MY_CUSTOM_SETTING}}
```

---

## Troubleshooting

### Command Not Found

**Problem:** `/init-claude` not recognized

**Solution:**
```powershell
# 1. Verify files installed
ls ~/.claude/commands/init-claude.*

# 2. Restart Claude Code CLI

# 3. Check if commands are loaded
# (Commands should auto-load from .claude/commands/)
```

### Framework Not Detected

**Problem:** Shows "unknown" framework when it should detect

**Solution:**
```powershell
# Manually run scanner to debug
powershell.exe -File ~/.claude/scripts/auto-init/scanner.ps1

# Check output - should show detected projectType
# If "unknown", ensure framework indicators exist:
#   - package.json (Node.js)
#   - requirements.txt (Python)
#   - go.mod (Go)
```

### PowerShell Execution Error

**Problem:** "Execution of scripts is disabled"

**Solution:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# If Restricted, update for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass (used by command handler)
powershell.exe -ExecutionPolicy Bypass -File script.ps1
```

### Template Not Found

**Problem:** "Template not found: nextjs.template.md"

**Solution:**
```powershell
# Verify templates exist
ls ~/.claude/templates/auto-init/

# Should show 7 templates + README
# If missing, reinstall the system
```

---

## Next Steps

- **Read:** [templates.md](./templates.md) - Template customization guide
- **Read:** [api.md](./api.md) - PowerShell script API reference
- **Read:** [troubleshooting.md](./troubleshooting.md) - Common issues and solutions
- **Explore:** Example projects in `examples/` directory
- **Customize:** Edit templates to match your preferences

---

## Support

- **GitHub Issues:** https://github.com/patichu0101/claude-config/issues
- **Documentation:** `docs/` directory
- **Examples:** `examples/` directory
- **Template Guide:** `.claude/templates/auto-init/README.md`

---

**Version:** 2.0.0
**Last Updated:** 2025-12-15
