#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: File Writer
.DESCRIPTION
    Safely writes CLAUDE.md and AGENT.md files with automatic backups.
    Updates .gitignore to exclude backup files.
.PARAMETER ValidatorResultJson
    JSON output from validator.ps1 (via pipeline or parameter)
.OUTPUTS
    JSON object with write result, files written, and backups created
.EXAMPLE
    .\scanner.ps1 | .\selector.ps1 | .\gather.ps1 | .\generator.ps1 | .\validator.ps1 | .\writer.ps1
#>

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$ValidatorResultJson
)

# Read from stdin if not provided as parameter
if (-not $ValidatorResultJson) {
    $ValidatorResultJson = [Console]::In.ReadToEnd()
}

# Parse validator result
try {
    $validatorResult = $ValidatorResultJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse validator result JSON: $_"
    exit 1
}

# Check if validation passed
if (-not $validatorResult.isValid) {
    $errorResult = @{
        success = $false
        errors = $validatorResult.errors
        message = "Validation failed. Files not written."
    }

    $errorResult | ConvertTo-Json -Depth 10 -Compress
    exit 1
}

# Get project path
$projectRoot = Get-Location
$filesWritten = @()
$backups = @()
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

#region Write CLAUDE.md

$claudeMdPath = Join-Path $projectRoot "CLAUDE.md"

# Backup existing file if it exists
if (Test-Path $claudeMdPath) {
    $backupPath = Join-Path $projectRoot "CLAUDE.md.backup.$timestamp"

    try {
        Copy-Item $claudeMdPath $backupPath -ErrorAction Stop
        $backups += $backupPath
        Write-Verbose "Backed up existing CLAUDE.md to $backupPath"
    }
    catch {
        Write-Error "Failed to backup existing CLAUDE.md: $_"
        exit 1
    }
}

# Write new CLAUDE.md
try {
    $validatorResult.generatorResult.claudeMdContent | Out-File -FilePath $claudeMdPath -Encoding UTF8 -ErrorAction Stop
    $filesWritten += $claudeMdPath
    Write-Verbose "Created CLAUDE.md at $claudeMdPath"
}
catch {
    Write-Error "Failed to write CLAUDE.md: $_"

    # Restore backup if write failed
    if ($backups.Count -gt 0 -and (Test-Path $backups[0])) {
        Copy-Item $backups[0] $claudeMdPath -Force
        Write-Warning "Restored backup due to write failure"
    }

    exit 1
}

#endregion

#region Write AGENT.md (if generated)

if ($validatorResult.generatorResult.agentMdContent) {
    $agentMdPath = Join-Path $projectRoot "AGENT.md"

    # Backup existing file if it exists
    if (Test-Path $agentMdPath) {
        $backupPath = Join-Path $projectRoot "AGENT.md.backup.$timestamp"

        try {
            Copy-Item $agentMdPath $backupPath -ErrorAction Stop
            $backups += $backupPath
            Write-Verbose "Backed up existing AGENT.md to $backupPath"
        }
        catch {
            Write-Error "Failed to backup existing AGENT.md: $_"
            exit 1
        }
    }

    # Write new AGENT.md
    try {
        $validatorResult.generatorResult.agentMdContent | Out-File -FilePath $agentMdPath -Encoding UTF8 -ErrorAction Stop
        $filesWritten += $agentMdPath
        Write-Verbose "Created AGENT.md at $agentMdPath"
    }
    catch {
        Write-Error "Failed to write AGENT.md: $_"

        # Restore backup if write failed
        if ($backups.Count -gt 1 -and (Test-Path $backups[1])) {
            Copy-Item $backups[1] $agentMdPath -Force
            Write-Warning "Restored backup due to write failure"
        }

        exit 1
    }
}

#endregion

#region Update .gitignore

$gitignorePath = Join-Path $projectRoot ".gitignore"
$gitignoreUpdated = $false

# Backup patterns to add
$backupPatterns = @(
    "# CLAUDE.md backups",
    "CLAUDE.md.backup.*",
    "AGENT.md.backup.*"
)

if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw

    # Check if backup patterns already exist
    $needsUpdate = $false
    foreach ($pattern in $backupPatterns) {
        if ($gitignoreContent -notmatch [regex]::Escape($pattern)) {
            $needsUpdate = $true
            break
        }
    }

    if ($needsUpdate) {
        try {
            # Add patterns to .gitignore
            Add-Content -Path $gitignorePath -Value ("`n" + ($backupPatterns -join "`n")) -ErrorAction Stop
            $gitignoreUpdated = $true
            Write-Verbose "Updated .gitignore with backup patterns"
        }
        catch {
            Write-Warning "Failed to update .gitignore: $_"
        }
    }
}
elseif ($backups.Count -gt 0) {
    # Create .gitignore if it doesn't exist and we created backups
    try {
        $backupPatterns -join "`n" | Out-File -FilePath $gitignorePath -Encoding UTF8 -ErrorAction Stop
        $gitignoreUpdated = $true
        Write-Verbose "Created .gitignore with backup patterns"
    }
    catch {
        Write-Warning "Failed to create .gitignore: $_"
    }
}

#endregion

# Build success result
$result = @{
    success = $true
    filesWritten = $filesWritten | ForEach-Object { $_ -replace [regex]::Escape($projectRoot), '.' }
    backups = $backups | ForEach-Object { $_ -replace [regex]::Escape($projectRoot), '.' }
    warnings = $validatorResult.warnings
    gitignoreUpdated = $gitignoreUpdated
    timestamp = $timestamp
    message = "Successfully generated $(filesWritten.Count) file(s)"
}

# Output result
$result | ConvertTo-Json -Depth 10 -Compress
