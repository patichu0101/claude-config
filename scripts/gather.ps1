#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: User Input Gatherer
.DESCRIPTION
    Interactive prompts to gather user preferences and customizations.
    Combines scan results with user input for template generation.
.PARAMETER SelectorResultJson
    JSON output from selector.ps1 (via pipeline or parameter)
.PARAMETER NonInteractive
    Skip interactive prompts and use defaults (for testing)
.OUTPUTS
    JSON object with selector result + user preferences
.EXAMPLE
    .\scanner.ps1 | .\selector.ps1 | .\gather.ps1
    .\scanner.ps1 | .\selector.ps1 | .\gather.ps1 -NonInteractive
#>

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$SelectorResultJson,

    [switch]$NonInteractive
)

# Read from stdin if not provided as parameter
if (-not $SelectorResultJson) {
    $SelectorResultJson = [Console]::In.ReadToEnd()
}

# Parse selector result
try {
    $selectorResult = $SelectorResultJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse selector result JSON: $_"
    exit 1
}

# Helper function for interactive prompts
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [string[]]$ValidOptions = @()
    )

    if ($NonInteractive) {
        return $Default
    }

    $fullPrompt = $Prompt
    if ($Default) {
        $fullPrompt += " (default: $Default)"
    }
    if ($ValidOptions.Count -gt 0) {
        $fullPrompt += " [$($ ValidOptions -join '/')]"
    }
    $fullPrompt += ": "

    Write-Host $fullPrompt -NoNewline -ForegroundColor Cyan
    $input = Read-Host

    # Use default if no input
    if ([string]::IsNullOrWhiteSpace($input) -and $Default) {
        return $Default
    }

    # Validate against options if provided
    if ($ValidOptions.Count -gt 0) {
        $lowerInput = $input.ToLower()
        $matchedOption = $ValidOptions | Where-Object { $_.ToLower() -eq $lowerInput } | Select-Object -First 1

        if ($matchedOption) {
            return $matchedOption
        }
        else {
            Write-Host "Invalid option. Using default: $Default" -ForegroundColor Yellow
            return $Default
        }
    }

    return $input
}

# Display banner
if (-not $NonInteractive) {
    Write-Host "`n=== CLAUDE.md Auto-Initialization ===" -ForegroundColor Green
    Write-Host "Detected: $($selectorResult.scanResult.framework.name)" -ForegroundColor Green
    if ($selectorResult.scanResult.framework.version) {
        Write-Host "Version: $($selectorResult.scanResult.framework.version)" -ForegroundColor Green
    }
    Write-Host "Template: $($selectorResult.templateName)" -ForegroundColor Green
    Write-Host "Confidence: $([math]::Round($selectorResult.scanResult.confidence * 100))%`n" -ForegroundColor $(if ($selectorResult.scanResult.confidence -gt 0.8) { "Green" } else { "Yellow" })
}

# Initialize user preferences
$userPreferences = @{}

# Q1: Project description
if (-not $NonInteractive) {
    Write-Host "`n--- Project Information ---" -ForegroundColor Cyan
}

$defaultDescription = "A $($selectorResult.scanResult.framework.name) project"
$description = Get-UserInput -Prompt "Project description" -Default $defaultDescription

$userPreferences.PROJECT_DESCRIPTION = $description

# Q2: Code style preference
if (-not $NonInteractive) {
    Write-Host "`n--- Code Style ---" -ForegroundColor Cyan
    Write-Host "1. Functional (default) - Prefer functional programming patterns"
    Write-Host "2. OOP - Object-oriented programming"
    Write-Host "3. Mixed - Combination of functional and OOP"
}

$codeStyleInput = Get-UserInput -Prompt "Code style" -Default "1" -ValidOptions @("1", "2", "3")
$codeStyle = switch ($codeStyleInput) {
    "2" { "oop" }
    "3" { "mixed" }
    default { "functional" }
}

$userPreferences.CODE_STYLE = $codeStyle

# Q3: Confirm detected dependencies (if any)
if ($selectorResult.scanResult.dependencies.PSObject.Properties.Count -gt 0) {
    if (-not $NonInteractive) {
        Write-Host "`n--- Dependencies ---" -ForegroundColor Cyan
        Write-Host "Detected dependencies: $($selectorResult.variables.DEPENDENCIES_LIST)"
    }

    $confirmDeps = Get-UserInput -Prompt "Are these correct?" -Default "Y" -ValidOptions @("Y", "N", "y", "n")

    if ($confirmDeps.ToLower() -eq "n") {
        $additionalDeps = Get-UserInput -Prompt "Enter additional dependencies (comma-separated)"

        if ($additionalDeps) {
            $customDeps = $additionalDeps -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            $userPreferences.CUSTOM_DEPS = $customDeps

            # Update dependencies list
            $allDeps = $selectorResult.variables.DEPENDENCIES_LIST
            if ($allDeps) {
                $allDeps += ", " + ($customDeps -join ", ")
            }
            else {
                $allDeps = ($customDeps -join ", ")
            }
            $selectorResult.variables.DEPENDENCIES_LIST = $allDeps
        }
    }
}

# Q4: Generate AGENT.md?
if (-not $NonInteractive) {
    Write-Host "`n--- Additional Files ---" -ForegroundColor Cyan
}

$generateAgent = Get-UserInput -Prompt "Generate AGENT.md as well?" -Default "Y" -ValidOptions @("Y", "N", "y", "n")
$userPreferences.GENERATE_AGENT = ($generateAgent.ToLower() -eq "y")

# Q5: Any special requirements?
if (-not $NonInteractive) {
    Write-Host "`n--- Special Requirements ---" -ForegroundColor Cyan
    Write-Host "1. None (default)"
    Write-Host "2. Security focus - Extra security guidelines"
    Write-Host "3. Performance focus - Performance optimization tips"
    Write-Host "4. Accessibility focus - A11y best practices"
}

$specialReqInput = Get-UserInput -Prompt "Special requirements" -Default "1" -ValidOptions @("1", "2", "3", "4")
$specialReq = switch ($specialReqInput) {
    "2" { "security" }
    "3" { "performance" }
    "4" { "accessibility" }
    default { "none" }
}

$userPreferences.SPECIAL_REQUIREMENTS = $specialReq

# Merge user preferences into variables
foreach ($key in $userPreferences.Keys) {
    $selectorResult.variables[$key] = $userPreferences[$key]
}

# Add user preferences to result
$selectorResult | Add-Member -MemberType NoteProperty -Name "userPreferences" -Value $userPreferences -Force

# Display summary
if (-not $NonInteractive) {
    Write-Host "`n--- Summary ---" -ForegroundColor Green
    Write-Host "Project: $($selectorResult.variables.PROJECT_NAME)"
    Write-Host "Framework: $($selectorResult.scanResult.framework.name)"
    Write-Host "Code Style: $codeStyle"
    Write-Host "Generate AGENT.md: $(if ($userPreferences.GENERATE_AGENT) { 'Yes' } else { 'No' })"
    if ($specialReq -ne "none") {
        Write-Host "Special Focus: $specialReq"
    }
    Write-Host ""
}

# Output result as JSON
$selectorResult | ConvertTo-Json -Depth 10 -Compress
