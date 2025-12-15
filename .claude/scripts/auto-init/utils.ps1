#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: Utility Functions
.DESCRIPTION
    Shared utility functions used across the auto-init pipeline.
    Functions for JSON handling, path operations, and formatting.
.NOTES
    This module is dot-sourced by other scripts as needed.
#>

#region JSON Utilities

function ConvertTo-JsonSafe {
    <#
    .SYNOPSIS
        Enhanced JSON conversion with depth control and error handling
    .PARAMETER Object
        Object to convert to JSON
    .PARAMETER Depth
        Maximum depth for nested objects (default: 10)
    .PARAMETER Compress
        Output single-line JSON (default: true)
    #>
    param(
        [Parameter(Mandatory)]
        $Object,

        [int]$Depth = 10,

        [switch]$Compress = $true
    )

    try {
        if ($Compress) {
            return ($Object | ConvertTo-Json -Depth $Depth -Compress -ErrorAction Stop)
        }
        else {
            return ($Object | ConvertTo-Json -Depth $Depth -ErrorAction Stop)
        }
    }
    catch {
        Write-Error "Failed to convert object to JSON: $_"
        return $null
    }
}

function ConvertFrom-JsonSafe {
    <#
    .SYNOPSIS
        Safe JSON parsing with error handling
    .PARAMETER Json
        JSON string to parse
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Json
    )

    if ([string]::IsNullOrWhiteSpace($Json)) {
        Write-Error "JSON string is empty or whitespace"
        return $null
    }

    try {
        return ($Json | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        Write-Error "Failed to parse JSON: $_"
        return $null
    }
}

#endregion

#region Path Utilities

function Test-PathSafe {
    <#
    .SYNOPSIS
        Cross-platform path existence check with error handling
    .PARAMETER Path
        Path to check
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    try {
        return (Test-Path $Path -ErrorAction SilentlyContinue)
    }
    catch {
        return $false
    }
}

function Get-RelativePathSafe {
    <#
    .SYNOPSIS
        Convert absolute path to relative path safely
    .PARAMETER Path
        Absolute path
    .PARAMETER BasePath
        Base path (defaults to current location)
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$BasePath = (Get-Location).Path
    )

    try {
        $relativePath = [System.IO.Path]::GetRelativePath($BasePath, $Path)
        return $relativePath -replace '\\', '/'  # Normalize to forward slashes
    }
    catch {
        # Fallback: simple string replacement
        $normalized = $Path -replace [regex]::Escape($BasePath), '.'
        return $normalized -replace '\\', '/'
    }
}

function Join-PathSafe {
    <#
    .SYNOPSIS
        Safe path joining that handles nulls and empty strings
    .PARAMETER Path
        Base path
    .PARAMETER ChildPath
        Child path to join
    #>
    param(
        [string]$Path,
        [string]$ChildPath
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $ChildPath
    }

    if ([string]::IsNullOrWhiteSpace($ChildPath)) {
        return $Path
    }

    try {
        return (Join-Path $Path $ChildPath -ErrorAction Stop)
    }
    catch {
        # Fallback: manual join
        return "$Path\$ChildPath"
    }
}

#endregion

#region String Utilities

function Format-ProjectName {
    <#
    .SYNOPSIS
        Sanitize project name for display
    .PARAMETER Name
        Raw project name
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    # Remove invalid characters and clean up
    $sanitized = $Name -replace '[<>:"/\\|?*]', ''  # Remove invalid Windows filename chars
    $sanitized = $sanitized.Trim()

    if ([string]::IsNullOrWhiteSpace($sanitized)) {
        return "my-project"
    }

    return $sanitized
}

function Get-FileSizeFormatted {
    <#
    .SYNOPSIS
        Format file size in human-readable format
    .PARAMETER Bytes
        File size in bytes
    #>
    param(
        [long]$Bytes
    )

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }
    elseif ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }
    elseif ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }
    else {
        return "$Bytes bytes"
    }
}

#endregion

#region Validation Utilities

function Test-ValidEmail {
    <#
    .SYNOPSIS
        Basic email validation
    .PARAMETER Email
        Email address to validate
    #>
    param(
        [string]$Email
    )

    if ([string]::IsNullOrWhiteSpace($Email)) {
        return $false
    }

    # Simple email regex
    return $Email -match '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
}

function Test-ValidUrl {
    <#
    .SYNOPSIS
        Basic URL validation
    .PARAMETER Url
        URL to validate
    #>
    param(
        [string]$Url
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $false
    }

    try {
        $uri = [System.Uri]$Url
        return $uri.IsAbsoluteUri
    }
    catch {
        return $false
    }
}

#endregion

#region Color Output

function Write-ColorOutput {
    <#
    .SYNOPSIS
        Write colored output to console
    .PARAMETER Message
        Message to write
    .PARAMETER Color
        Console color (default: White)
    .PARAMETER NoNewline
        Suppress newline
    #>
    param(
        [string]$Message,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White,
        [switch]$NoNewline
    )

    $params = @{
        Object = $Message
        ForegroundColor = $Color
    }

    if ($NoNewline) {
        $params.NoNewline = $true
    }

    Write-Host @params
}

#endregion

# Export functions (for dot-sourcing)
Export-ModuleMember -Function *
