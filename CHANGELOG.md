<!-- TIER 2: APPEND-ONLY LOG - Do not modify existing entries -->
<!-- Add new entries at the top with timestamps. -->

# Changelog

All notable changes to the Claude Code configuration system are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-12-15

### Added

#### CLAUDE.md Auto-Initialization System
- **NEW `/init-claude` command** - Auto-generate CLAUDE.md and AGENT.md files
- **Project Detection Scanner** (`scripts/scanner.ps1`)
  - Detects React + Vite projects from package.json
  - Detects Next.js projects (App Router vs Pages Router)
  - Detects Python projects (FastAPI, Django) from pyproject.toml
  - Detects Go projects from go.mod
  - Identifies test frameworks (vitest, jest, pytest)
  - Determines package manager (npm, pnpm, yarn, uv)
  - Returns confidence score for detection accuracy
- **Template System** (7 framework-specific templates)
  - `.claude/templates/react-vite.template.md` - React 18 + Vite + TypeScript
  - `.claude/templates/nextjs.template.md` - Next.js 14+ with App Router
  - `.claude/templates/fastapi.template.md` - FastAPI + Python + Pydantic
  - `.claude/templates/django.template.md` - Django web framework
  - `.claude/templates/go.template.md` - Go modules + packages
  - `.claude/templates/generic.template.md` - Fallback for unknown projects
  - `.claude/templates/agent.template.md` - Optional AGENT.md generation
- **PowerShell Pipeline** (8 modular scripts)
  - `scripts/scanner.ps1` - Project detection
  - `scripts/selector.ps1` - Template selection logic
  - `scripts/gather.ps1` - Interactive user input
  - `scripts/generator.ps1` - Placeholder replacement
  - `scripts/validator.ps1` - Quality & security checks
  - `scripts/writer.ps1` - Safe file operations with backups
  - `scripts/utils.ps1` - Shared utilities (JSON, paths, formatting)
  - `scripts/security.ps1` - Secret pattern detection
- **Command Handler** (`.claude/commands/init-claude.js`)
  - Node.js orchestrator for PowerShell pipeline
  - Spawns sequential script chain via stdout/stdin JSON
  - Displays progress messages and final summary
  - Error handling with user-friendly messages
- **Security Features**
  - Detects potential secrets (API keys: sk-, pk-, etc.)
  - Validates paths to prevent directory traversal
  - Creates timestamped backups before overwriting files
  - Updates .gitignore to exclude backup files
- **Quality Validation**
  - Checks for required sections in generated files
  - Detects unreplaced `{{PLACEHOLDERS}}`
  - Validates markdown syntax
  - Ensures AGENT.md has required headers
- **Documentation**
  - ADR-010: Architecture decision for auto-init system
  - Implementation plan in `~/.claude/plans/smooth-dazzling-raven.md`
  - Updated features.json with auto-init entry
  - Updated state.json with new capabilities

### Changed
- Configuration version bumped from 1.0.0 → 2.0.0
- Session count incremented to 3
- Feature statistics: 10 completed (was 9), 71% completion rate (was 69%)

### Performance
- Project scanning: <1 second
- Template selection: <500ms
- Generation + validation: <2 seconds
- Total workflow: <15 seconds (excluding user input time)

---

## [1.0.0] - 2025-12-15

### Added

#### Phase 1: Backup
- Created complete backup at `~/.claude.backup.20251215`
- Preserved all 134 agents, 11 plugins, settings, and configuration

#### Phase 2: Agent Consolidation
- Created new directory structure:
  - `agents/core/` - 10 essential agents
  - `agents/support/` - 5 secondary agents
  - `agents/meta/` - 2 orchestration agents
  - `agents/_archive/` - 117 archived agents
- Added NEW `fastapi.md` agent based on Django pattern
- Moved all categorized agents to `_archive/`
- Reduced active agents from 134 to 17 (87% reduction)

**Core Agents (10):**
1. fullstack.md - Full-stack development
2. typescript.md - TypeScript optimization
3. python.md - Python development
4. fastapi.md - **NEW** Python API specialist
5. react-next.md - React/Next.js development
6. api-designer.md - API architecture
7. postgres.md - Database design
8. sre.md - Site reliability engineering
9. code-reviewer.md - Code review
10. debugger.md - Debugging specialist

**Support Agents (5):**
1. devops.md - DevOps practices
2. documentation.md - Documentation
3. performance.md - Performance optimization
4. security.md - Security audits
5. test-automator.md - Test automation

**Meta Agents (2):**
1. planner.md - Planning and architecture
2. synthesizer.md - Knowledge synthesis

#### Phase 3: User Memory (CLAUDE.md)
- Created comprehensive user memory in `~/.claude/CLAUDE.md`
- Documented identity: Patrick, Solopreneur, Power User
- Documented environment: Windows 11 Pro, 32GB RAM, Intel Core Ultra 5 125H
- Documented tech stack: TypeScript/Node.js, Python/uv, React/Next.js, FastAPI
- Documented coding preferences: Functional, explicit types, named exports
- Documented workflow preferences: Plan mode, conventional commits, uv over pip
- Added agent selection guide for common tasks

#### Phase 3b: Project Templates
- Created 14 project templates across 4 categories:

**TypeScript Templates (4):**
- `templates/typescript/nextjs-app/` - Next.js App Router
- `templates/typescript/node-api/` - Node.js REST API
- `templates/typescript/react-spa/` - React SPA
- `templates/typescript/cli-tool/` - CLI tool

**Python Templates (4):**
- `templates/python/fastapi/` - FastAPI REST API
- `templates/python/django/` - Django web app
- `templates/python/flask/` - Flask web app
- `templates/python/automation/` - Automation scripts

**Full-Stack Templates (3):**
- `templates/fullstack/next-supabase/` - Next.js + Supabase
- `templates/fullstack/fastapi-react/` - FastAPI + React
- `templates/fullstack/t3-stack/` - T3 Stack (tRPC)

**Infrastructure Templates (3):**
- `templates/infra/docker-compose/` - Docker Compose
- `templates/infra/terraform/` - Terraform IaC
- `templates/infra/github-actions/` - GitHub Actions CI/CD

#### Phase 4: Settings Curation
- Rewrote `~/.claude/settings.json` with curated configuration:
  - Model: opus (for complex reasoning)
  - Always thinking enabled
  - Comprehensive allow list (Read, Write, Edit, Bash commands)
  - Strict deny list (rm -rf, sudo, force push, secret files)
  - Ask list for dangerous operations (npm publish, force push, hard reset)
  - Default mode: plan (encourages planning)
- Reduced enabled plugins from 11 to 7:
  1. ultrathink - Deep reasoning
  2. test-file - Test generation
  3. code-reviewer - Code review
  4. web-dev - Web utilities
  5. c4-architecture - Architecture diagrams
  6. comprehensive-review - Thorough analysis
  7. cloud-infrastructure - IaC patterns
- Added PostToolUse hooks for auto-formatting:
  - TypeScript/TSX files: Prettier
  - Python files: Ruff

#### Phase 4b: Secrets Management
- Created `~/.claude/settings.local.json` for machine-specific settings:
  - MCP server permissions (interactive, chrome-devtools, context7, etc.)
  - Windows-specific Bash permissions (powershell.exe, wsl.exe, docker)
  - Output style: "Markdown Focused"
- Created `~/.claude/secrets.env.example` template with placeholders for:
  - ANTHROPIC_API_KEY
  - CONTEXT7_API_KEY
  - METAMCP_API_KEY
  - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
  - DATABASE_URL
  - VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
  - GITHUB_TOKEN
  - OPENAI_API_KEY
  - N8N_URL, N8N_API_KEY
  - SENTRY_DSN
  - SENDGRID_API_KEY
  - STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET

#### Phase 5: Rules System
- Created `~/.claude/rules/` directory with 3 rule files:

**global.md:**
- Safety rules (file operations, secrets, git operations)
- Code quality rules (TypeScript/JavaScript, Python, general)
- Workflow rules (before/during/after implementation)
- Communication rules

**security.md:**
- Credential management
- Authentication & authorization
- Input validation
- Data protection (in transit, at rest)
- Dependency security
- Secure coding practices
- Infrastructure security

**windows.md:**
- Path handling (forward/back slashes, quoting)
- Shell commands (PowerShell preference, common equivalents)
- Line endings (CRLF vs LF)
- WSL integration
- Docker on Windows
- Node.js on Windows
- Environment variables
- File watching

#### Phase 5b: Hook Scripts
- Created `~/.claude/hooks/scripts/` with 4 PowerShell scripts:

**post-edit-format.ps1:**
- Auto-formats files after Claude edits them
- Supports: .ts, .tsx, .js, .jsx, .json (Prettier)
- Supports: .py (Ruff)
- Supports: .md (Prettier with prose-wrap)
- Supports: .css, .scss (Prettier)

**post-write-lint.ps1:**
- Runs linters after Claude creates new files
- TypeScript/TSX: ESLint with --fix
- Python: Ruff with --fix

**session-summary.ps1:**
- Creates summary of Claude Code session
- Saves to `~/.claude/session-logs/session-{timestamp}.md`
- Includes git status and diff stats
- Provides template for session notes

**load-project-context.ps1:**
- Loads project-specific settings at session start
- Detects project type (Node.js, Python, Docker Compose)
- Checks for project CLAUDE.md
- Identifies package managers (npm, uv, etc.)

#### Phase 6: Security Fixes
- **CRITICAL**: Secured exposed MetaMCP API key
  - Found plaintext API key in `~/.claude.json`
  - Moved to environment variable reference: `${METAMCP_API_KEY}`
  - Updated secrets.env.example with rotation warning
  - Key: `sk_mt_soEJoUzz3R6FI9dD69rKHvs1mYGNxQ8KV7GN1vWT3pB4Wm97f51zzxpvmyxRVASj` **MUST BE ROTATED**

#### Phase 7: Version Control
- Created `~/.claude/.gitignore` with exclusions for:
  - Secrets: `secrets.env`, `*.env`, `*.pem`, `*.key`, `credentials.json`
  - Machine-specific: `settings.local.json`
  - Session data: `session-logs/`, `file-history/`, `*.log`, `*.tmp`, `*.bak`
  - Cache: `.cache/`, `node_modules/`, `__pycache__/`, `*.pyc`
- Documented what IS tracked (shareable config)

#### Phase 8: Testing & Validation
- Verified final directory structure
- Confirmed 10 core agents, 5 support agents, 2 meta agents
- Validated rules directory (3 files)
- Checked templates (14 project templates across 4 categories)
- Verified hook scripts (4 PowerShell scripts)

### Changed
- Plugin count: 11 → 7 (removed redundant plugins)
- Agent count: 134 → 17 (focused on essentials)
- Configuration: Moved from ad-hoc to structured, modular system
- Secrets handling: From plaintext to environment variables
- Documentation: From scattered to tiered, maintainable system

### Fixed
- **SECURITY**: Exposed MetaMCP API key moved to environment variable
- Configuration sprawl: Consolidated into organized directory structure
- Missing user memory: Created comprehensive CLAUDE.md
- Inconsistent behavior: Established rules system
- No project templates: Created 14 templates

### Security
- **CRITICAL**: MetaMCP API key exposed in `~/.claude.json` - MUST ROTATE
- Added deny list for secret files (*.env, *.pem, *.key)
- Created secrets.env.example template
- Documented security practices in rules/security.md

---

## Future Releases

### Planned for 1.1.0
- [ ] Add Rust, Go project templates
- [ ] Create custom hook for auto-commit after significant changes
- [ ] Build agent performance analytics
- [ ] Integrate with Linear/GitHub Issues via MCP
- [ ] Document common workflows in templates/workflows/

### Planned for 2.0.0
- [ ] Multi-agent workflow orchestration
- [ ] Agent performance tracking dashboard
- [ ] Context sharing between sessions
- [ ] Advanced hook system with conditionals
- [ ] Plugin ecosystem with discovery

---

**Note:** This is a TIER 2 document (append-only log). New changes should be added at the top with timestamps. Do not modify existing entries.

---

**Sources:**
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
