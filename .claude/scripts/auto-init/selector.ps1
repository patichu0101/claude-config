#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: Template Selector
.DESCRIPTION
    Selects the best template based on project scan results.
    Maps project types to template files and extracts variables for placeholder replacement.
.PARAMETER ScanResultJson
    JSON output from scanner.ps1 (via pipeline or parameter)
.OUTPUTS
    JSON object with template path, variables, and scan result
.EXAMPLE
    .\scanner.ps1 | .\selector.ps1
#>

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$ScanResultJson
)

# Read from stdin if not provided as parameter
if (-not $ScanResultJson) {
    $ScanResultJson = [Console]::In.ReadToEnd()
}

# Parse scan result
try {
    $scanResult = $ScanResultJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse scan result JSON: $_"
    exit 1
}

# Get base path for templates (from .claude/scripts/auto-init/ to .claude/)
$claudeBasePath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$templatesDir = Join-Path $claudeBasePath "templates" | Join-Path -ChildPath "auto-init"

# Template mapping
$templateMap = @{
    "nextjs"      = "nextjs.template.md"
    "react-vite"  = "react-vite.template.md"
    "react"       = "react-vite.template.md"  # Fallback to react-vite
    "vite"        = "react-vite.template.md"  # Fallback to react-vite
    "fastapi"     = "fastapi.template.md"
    "django"      = "django.template.md"
    "flask"       = "django.template.md"      # Fallback to django
    "go"          = "go.template.md"
    "rust"        = "go.template.md"          # Fallback to go (similar patterns)
    "python"      = "fastapi.template.md"     # Generic Python → FastAPI template
    "nodejs"      = "generic.template.md"     # Generic Node.js
    "unknown"     = "generic.template.md"     # Fallback
}

# Select template based on project type
$templateFileName = $templateMap[$scanResult.projectType]
if (-not $templateFileName) {
    $templateFileName = "generic.template.md"
}

$templatePath = Join-Path $templatesDir $templateFileName

# Verify template exists
if (-not (Test-Path $templatePath)) {
    Write-Warning "Template not found: $templatePath. Using generic template."
    $templatePath = Join-Path $templatesDir "generic.template.md"

    # If even generic doesn't exist, error out
    if (-not (Test-Path $templatePath)) {
        Write-Error "Generic template not found. Templates directory may be incomplete."
        exit 1
    }
}

# Extract project name from path
$projectName = Split-Path -Leaf $scanResult.projectPath

# Build variables for placeholder replacement
$variables = @{
    PROJECT_NAME        = $projectName
    FRAMEWORK           = $scanResult.framework.name
    FRAMEWORK_VERSION   = $scanResult.framework.version
    PACKAGE_MANAGER     = $scanResult.packageManager
    TEST_FRAMEWORK      = $scanResult.testFramework
    ROUTER_TYPE         = $scanResult.framework.router
    PROJECT_PATH        = $scanResult.projectPath
    GENERATED_DATE      = (Get-Date -Format "yyyy-MM-dd")
    HAS_TESTS           = $scanResult.hasTests
    CONFIDENCE          = $scanResult.confidence
}

# Build dependencies list (for display in template)
$dependenciesList = @()
if ($scanResult.dependencies -and $scanResult.dependencies.PSObject.Properties.Count -gt 0) {
    # Get top 10 most important dependencies (exclude dev tools)
    $excludePatterns = @("@types/", "eslint", "prettier", "typescript", "@typescript-eslint")

    $scanResult.dependencies.PSObject.Properties | ForEach-Object {
        $depName = $_.Name
        $isExcluded = $false

        foreach ($pattern in $excludePatterns) {
            if ($depName -like "*$pattern*") {
                $isExcluded = $true
                break
            }
        }

        if (-not $isExcluded) {
            $dependenciesList += "$depName ($($_.Value))"
        }
    }

    # Limit to top 10
    $dependenciesList = $dependenciesList | Select-Object -First 10
}

$variables.DEPENDENCIES_LIST = ($dependenciesList -join ", ")

# Determine code style (can be overridden by user input later)
$variables.CODE_STYLE = "functional"  # Default

# Framework-specific variables
switch ($scanResult.projectType) {
    "nextjs" {
        $variables.SERVER_COMPONENTS = $true
        $variables.API_ROUTES = $true
    }
    "react-vite" {
        $variables.HMR_PORT = "5173"
        $variables.VITE_CONFIG = $true
    }
    "fastapi" {
        $variables.ASYNC_SUPPORT = $true
        $variables.PYDANTIC_VERSION = "v2"
    }
    "django" {
        $variables.APPS_STRUCTURE = (Test-Path (Join-Path $scanResult.projectPath "apps"))
        $variables.MIGRATIONS = $true
    }
    "go" {
        $variables.MODULES_SUPPORT = $true
    }
}

# Build result object
$result = @{
    templatePath = $templatePath
    templateName = $templateFileName
    variables = $variables
    scanResult = $scanResult
}

# Output as JSON
$result | ConvertTo-Json -Depth 10 -Compress
