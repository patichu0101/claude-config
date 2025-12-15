#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: Security Utilities
.DESCRIPTION
    Security-related functions for secret detection and path validation.
    Used by validator and writer to prevent security issues.
.NOTES
    This module is dot-sourced by other scripts as needed.
#>

#region Secret Detection

# Secret patterns to detect in content
$script:SecretPatterns = @(
    @{
        Pattern = 'sk-[a-zA-Z0-9]{20,}'
        Name = 'OpenAI API key'
        Severity = 'Critical'
    },
    @{
        Pattern = 'pk_(live|test)_[a-zA-Z0-9]{24,}'
        Name = 'Stripe API key'
        Severity = 'Critical'
    },
    @{
        Pattern = 'ghp_[a-zA-Z0-9]{36}'
        Name = 'GitHub Personal Access Token'
        Severity = 'Critical'
    },
    @{
        Pattern = 'xoxb-[0-9]{10,}-[a-zA-Z0-9]{24,}'
        Name = 'Slack Bot Token'
        Severity = 'Critical'
    },
    @{
        Pattern = 'AIza[a-zA-Z0-9_-]{35}'
        Name = 'Google API key'
        Severity = 'Critical'
    },
    @{
        Pattern = 'AKIA[A-Z0-9]{16}'
        Name = 'AWS Access Key ID'
        Severity = 'Critical'
    },
    @{
        Pattern = '[a-zA-Z0-9/+]{40}'
        Name = 'AWS Secret Access Key'
        Severity = 'High'
    },
    @{
        Pattern = '(password|secret|api_key|token|auth)\s*[:=]\s*["\x27]([^"\x27\s]{8,})["\x27]'
        Name = 'Generic secret in key-value format'
        Severity = 'Medium'
    },
    @{
        Pattern = 'Bearer\s+[a-zA-Z0-9\-._~+/]+=*'
        Name = 'Bearer token'
        Severity = 'High'
    }
)

function Test-SecretPattern {
    <#
    .SYNOPSIS
        Detect potential secrets in content
    .PARAMETER Content
        Content to scan for secrets
    .PARAMETER Strict
        Use strict mode (report medium severity findings)
    .OUTPUTS
        Array of detected secrets with details
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Content,

        [switch]$Strict
    )

    $detectedSecrets = @()

    foreach ($pattern in $script:SecretPatterns) {
        # Skip medium severity if not in strict mode
        if (-not $Strict -and $pattern.Severity -eq 'Medium') {
            continue
        }

        $matches = [regex]::Matches($Content, $pattern.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

        foreach ($match in $matches) {
            $detectedSecrets += @{
                Pattern = $pattern.Name
                Severity = $pattern.Severity
                Value = $match.Value.Substring(0, [Math]::Min(20, $match.Value.Length)) + '...'  # Truncate for safety
                Position = $match.Index
            }
        }
    }

    return $detectedSecrets
}

function Remove-SensitiveData {
    <#
    .SYNOPSIS
        Redact sensitive information from logs
    .PARAMETER Content
        Content to redact
    .OUTPUTS
        Redacted content with secrets masked
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Content
    )

    $redacted = $Content

    foreach ($pattern in $script:SecretPatterns) {
        if ($pattern.Severity -in @('Critical', 'High')) {
            $redacted = [regex]::Replace($redacted, $pattern.Pattern, '[REDACTED-' + $pattern.Name.ToUpper() + ']')
        }
    }

    return $redacted
}

#endregion

#region Path Validation

# Allowed read paths (whitelist)
$script:AllowedReadPaths = @(
    'package.json',
    'pyproject.toml',
    'go.mod',
    'Cargo.toml',
    '*.lock',
    '*.json',
    '*.md',
    '*.txt',
    'src/*',
    'app/*',
    'lib/*',
    'tests/*',
    '.claude/*'
)

# Blocked read paths (blacklist)
$script:BlockedReadPaths = @(
    '.env',
    '.env.*',
    'secrets.*',
    '*.pem',
    '*.key',
    '*.crt',
    '*.p12',
    '*.pfx',
    'id_rsa',
    'id_dsa',
    'credentials.json',
    '.git/config',
    '/etc/*',
    '/root/*',
    'C:\Windows\*',
    '$env:USERPROFILE\.ssh\*'
)

# Allowed write paths (whitelist)
$script:AllowedWritePaths = @(
    'CLAUDE.md',
    'AGENT.md',
    'CLAUDE.md.backup.*',
    'AGENT.md.backup.*',
    '.gitignore'
)

# Blocked write paths (blacklist)
$script:BlockedWritePaths = @(
    'package.json',
    'pyproject.toml',
    'go.mod',
    '.git/*',
    '.env',
    '*.lock',
    '/etc/*',
    '/root/*',
    'C:\Windows\*'
)

function Test-AllowedPath {
    <#
    .SYNOPSIS
        Validate if a path is allowed for read/write operations
    .PARAMETER Path
        Path to validate
    .PARAMETER Operation
        Operation type: 'read' or 'write'
    .OUTPUTS
        Boolean indicating if path is allowed
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateSet('read', 'write')]
        [string]$Operation
    )

    # Normalize path
    $normalizedPath = $Path -replace '\\', '/'

    # Get appropriate lists based on operation
    if ($Operation -eq 'read') {
        $allowedPatterns = $script:AllowedReadPaths
        $blockedPatterns = $script:BlockedReadPaths
    }
    else {
        $allowedPatterns = $script:AllowedWritePaths
        $blockedPatterns = $script:BlockedWritePaths
    }

    # Check blacklist first (deny takes precedence)
    foreach ($pattern in $blockedPatterns) {
        if ($normalizedPath -like $pattern) {
            Write-Verbose "Path blocked by pattern '$pattern': $normalizedPath"
            return $false
        }
    }

    # Check whitelist
    foreach ($pattern in $allowedPatterns) {
        if ($normalizedPath -like "*$pattern*") {
            return $true
        }
    }

    # Default deny if not in whitelist
    Write-Verbose "Path not in whitelist: $normalizedPath"
    return $false
}

function Test-PathTraversal {
    <#
    .SYNOPSIS
        Detect path traversal attempts
    .PARAMETER Path
        Path to check
    .OUTPUTS
        Boolean indicating if path contains traversal patterns
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    # Check for common path traversal patterns
    $traversalPatterns = @(
        '\.\.',       # ..
        '\.\./',      # ../
        '\.\.\\',     # ..\
        '%2e%2e',     # URL-encoded ..
        '%252e%252e'  # Double URL-encoded ..
    )

    foreach ($pattern in $traversalPatterns) {
        if ($Path -match [regex]::Escape($pattern)) {
            return $true
        }
    }

    return $false
}

#endregion

#region Input Sanitization

function ConvertTo-SafeString {
    <#
    .SYNOPSIS
        Sanitize user input to prevent injection
    .PARAMETER Input
        User input to sanitize
    .PARAMETER AllowedChars
        Regex pattern of allowed characters (default: alphanumeric, space, dash, underscore)
    .OUTPUTS
        Sanitized string
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Input,

        [string]$AllowedChars = '[a-zA-Z0-9 \-_]'
    )

    if ([string]::IsNullOrWhiteSpace($Input)) {
        return ""
    }

    # Extract only allowed characters
    $safe = [regex]::Matches($Input, $AllowedChars) | ForEach-Object { $_.Value } | Join-String

    return $safe.Trim()
}

#endregion

# Export functions (for dot-sourcing)
Export-ModuleMember -Function *
