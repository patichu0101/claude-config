# Claude Config - Auto-Init System

Automatically generate CLAUDE.md and AGENT.md files for your projects with framework-specific best practices.

## Features

- 🔍 **Automatic Framework Detection**: Recognizes Next.js, React+Vite, FastAPI, Django, Go, and more
- 📝 **Framework-Specific Templates**: 7 production-ready templates with best practices
- 🔒 **Security Validation**: Detects and prevents secrets in generated files
- 💾 **Safe File Operations**: Automatic backups before overwriting
- ⚡ **Fast**: Complete generation in <15 seconds

## Supported Frameworks

| Framework | Template | Features |
|-----------|----------|----------|
| Next.js 14+ (App Router) | `nextjs.template.md` | Server/Client Components, Route Handlers, Metadata API |
| React 18 + Vite | `react-vite.template.md` | Component patterns, Hooks, State management |
| FastAPI (Python) | `fastapi.template.md` | Async/await, Pydantic v2, Type hints |
| Django (Python) | `django.template.md` | ORM patterns, Migrations, Admin |
| Go | `go.template.md` | Modules, Goroutines, Error handling |
| Generic | `generic.template.md` | Universal fallback template |

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/patichu0101/claude-config.git

# Copy .claude/ directory to your project root
cp -r claude-config/.claude your-project/
```

### Usage

```bash
# Navigate to your project
cd your-project

# Run the init command (in Claude Code)
/init-claude
```

The system will:
1. 🔍 Scan your project to detect the framework
2. ❓ Ask a few customization questions
3. ✨ Generate CLAUDE.md (and optionally AGENT.md)
4. 💾 Create backups of existing files
5. ✅ Validate the output

## Examples

See the `examples/` directory for complete generated files:

- [`examples/nextjs/`](examples/nextjs/) - Next.js 14 App Router project
- [`examples/fastapi/`](examples/fastapi/) - FastAPI + Pydantic v2 project
- [`examples/react-vite/`](examples/react-vite/) - React 18 + Vite project

## Documentation

- [Getting Started](docs/getting-started.md) - Detailed installation and usage
- [Templates](docs/templates.md) - Template customization guide
- [API Reference](docs/api.md) - PowerShell script API

## Architecture

```
User runs /init-claude
  ↓
init-claude.js (Node.js orchestrator)
  ↓
PowerShell Pipeline:
  scanner.ps1 → selector.ps1 → gather.ps1 →
  generator.ps1 → validator.ps1 → writer.ps1
  ↓
CLAUDE.md + AGENT.md (optional)
```

## Requirements

- **PowerShell**: 5.1+ or PowerShell 7+
- **Node.js**: 18+ (for Claude Code integration)
- **Claude Code**: Latest version

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Credits

Built with ❤️ by [Patrick](https://github.com/patichu0101) as part of the claude-config project.
