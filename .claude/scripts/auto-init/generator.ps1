#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: Content Generator
.DESCRIPTION
    Processes templates and replaces placeholders with actual values.
    Generates CLAUDE.md and optionally AGENT.md content.
.PARAMETER GathererResultJson
    JSON output from gather.ps1 (via pipeline or parameter)
.OUTPUTS
    JSON object with generated content and metadata
.EXAMPLE
    .\scanner.ps1 | .\selector.ps1 | .\gather.ps1 | .\generator.ps1
#>

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$GathererResultJson
)

# Read from stdin if not provided as parameter
if (-not $GathererResultJson) {
    $GathererResultJson = [Console]::In.ReadToEnd()
}

# Parse gatherer result
try {
    $gathererResult = $GathererResultJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse gatherer result JSON: $_"
    exit 1
}

# Helper function to replace placeholders
function Replace-Placeholders {
    param(
        [string]$Content,
        [hashtable]$Variables
    )

    $result = $Content

    # Replace {{VARIABLE}} placeholders
    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]

        # Convert value to string
        if ($value -is [array]) {
            $value = $value -join ", "
        }
        elseif ($null -eq $value) {
            $value = ""
        }
        elseif ($value -is [bool]) {
            $value = if ($value) { "true" } else { "false" }
        }
        else {
            $value = $value.ToString()
        }

        # Replace placeholder
        $placeholder = "{{$key}}"
        $result = $result -replace [regex]::Escape($placeholder), $value
    }

    return $result
}

# Helper function to process conditional sections
function Process-Conditionals {
    param(
        [string]$Content,
        [hashtable]$Variables
    )

    # Process {{#IF VARIABLE}}...{{/IF}} blocks
    $pattern = '(?s)\{\{#IF\s+(\w+)\}\}(.*?)\{\{/IF\}\}'

    $result = [regex]::Replace($Content, $pattern, {
        param($match)

        $condition = $match.Groups[1].Value
        $block = $match.Groups[2].Value

        # Check if condition variable exists and is truthy
        if ($Variables.ContainsKey($condition)) {
            $value = $Variables[$condition]

            # Truthy check
            if ($value -is [bool] -and $value) {
                return $block
            }
            elseif ($value -is [string] -and -not [string]::IsNullOrWhiteSpace($value)) {
                return $block
            }
            elseif ($value -ne $null -and $value -ne 0 -and $value -ne "false") {
                return $block
            }
        }

        # Condition not met, remove block
        return ""
    })

    return $result
}

# Read template file
try {
    $templateContent = Get-Content $gathererResult.templatePath -Raw -ErrorAction Stop
}
catch {
    Write-Error "Failed to read template file: $($gathererResult.templatePath) - $_"
    exit 1
}

# Convert variables to hashtable for easier processing
$variables = @{}
$gathererResult.variables.PSObject.Properties | ForEach-Object {
    $variables[$_.Name] = $_.Value
}

# Process CLAUDE.md template
Write-Verbose "Processing CLAUDE.md template: $($gathererResult.templatePath)"

# Step 1: Process conditional sections
$claudeMdContent = Process-Conditionals -Content $templateContent -Variables $variables

# Step 2: Replace placeholders
$claudeMdContent = Replace-Placeholders -Content $claudeMdContent -Variables $variables

# Generate AGENT.md if requested
$agentMdContent = $null

if ($gathererResult.userPreferences.GENERATE_AGENT -eq $true) {
    $agentTemplatePath = Join-Path (Split-Path $gathererResult.templatePath) "agent.template.md"

    if (Test-Path $agentTemplatePath) {
        Write-Verbose "Processing AGENT.md template: $agentTemplatePath"

        try {
            $agentTemplateContent = Get-Content $agentTemplatePath -Raw -ErrorAction Stop

            # Process conditionals
            $agentMdContent = Process-Conditionals -Content $agentTemplateContent -Variables $variables

            # Replace placeholders
            $agentMdContent = Replace-Placeholders -Content $agentMdContent -Variables $variables
        }
        catch {
            Write-Warning "Failed to generate AGENT.md: $_"
            $agentMdContent = $null
        }
    }
    else {
        Write-Warning "AGENT.md template not found: $agentTemplatePath"
    }
}

# Build metadata
$metadata = @{
    template = $gathererResult.templateName
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    framework = $gathererResult.scanResult.framework.name
    version = $gathererResult.scanResult.framework.version
    confidence = $gathererResult.scanResult.confidence
    variables = $variables
}

# Build result object
$result = @{
    claudeMdContent = $claudeMdContent
    agentMdContent = $agentMdContent
    metadata = $metadata
    generatedFiles = @()
}

# Track which files will be generated
if ($claudeMdContent) {
    $result.generatedFiles += "CLAUDE.md"
}
if ($agentMdContent) {
    $result.generatedFiles += "AGENT.md"
}

# Output as JSON
$result | ConvertTo-Json -Depth 10 -Compress
