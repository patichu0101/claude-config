# Contributing to Claude Config

Thank you for considering contributing to Claude Config!

## How to Contribute

### Reporting Bugs

Open an issue with:
- Description of the bug
- Steps to reproduce
- Expected vs actual behavior
- System info (OS, PowerShell version, Node.js version)

### Suggesting Features

Open an issue with:
- Use case description
- Proposed solution
- Alternative approaches considered

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly (see Testing section)
5. Commit with conventional commits (`feat:`, `fix:`, `docs:`, etc.)
6. Push to your fork
7. Open a pull request

## Testing

### Manual Testing Checklist
- [ ] Test with Next.js project
- [ ] Test with FastAPI project
- [ ] Test with empty directory (generic template)
- [ ] Verify backups are created
- [ ] Verify no secrets in output

## Code Style

### PowerShell
- Use approved verbs (`Get-`, `Set-`, `New-`, etc.)
- Comment functions with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`
- Use `-ErrorAction Stop` for critical operations

### JavaScript
- Use ES6+ syntax
- Prefer `const` over `let`
- No `console.log` in production code

## License

By contributing, you agree your contributions will be licensed under the MIT License.
