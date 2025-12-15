#Requires -Version 5.1
<#
.SYNOPSIS
    CLAUDE.md Auto-Init: Project Scanner
.DESCRIPTION
    Detects project type, framework, dependencies, and test configuration
    from package.json, pyproject.toml, go.mod, and directory structure.
    Outputs structured JSON to stdout for pipeline consumption.
.PARAMETER ProjectPath
    Path to the project root (defaults to current directory)
.OUTPUTS
    JSON object with project detection results
.EXAMPLE
    .\scanner.ps1
    .\scanner.ps1 -ProjectPath "C:\Projects\my-app"
#>

param(
    [string]$ProjectPath = (Get-Location).Path
)

# Ensure we're in the project directory
if (-not (Test-Path $ProjectPath)) {
    Write-Error "Project path does not exist: $ProjectPath"
    exit 1
}

Set-Location $ProjectPath

# Initialize result object
$result = @{
    projectType = "unknown"
    framework = @{
        name = $null
        version = $null
        router = $null
    }
    dependencies = @{}
    hasTests = $false
    testFramework = $null
    packageManager = $null
    confidence = 0.0
    projectPath = $ProjectPath
    scannedAt = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Helper function to parse JSON safely
function Get-JsonContent {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop
        return ($content | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        Write-Warning "Failed to parse JSON from $FilePath : $_"
        return $null
    }
}

# Helper function to check if path contains pattern
function Test-PathPattern {
    param(
        [string]$Pattern,
        [string]$BasePath = $ProjectPath
    )

    return (Get-ChildItem -Path $BasePath -Filter $Pattern -Recurse -ErrorAction SilentlyContinue -Depth 2 | Select-Object -First 1) -ne $null
}

#region Node.js / JavaScript / TypeScript Detection

$packageJsonPath = Join-Path $ProjectPath "package.json"
if (Test-Path $packageJsonPath) {
    $pkg = Get-JsonContent -FilePath $packageJsonPath

    if ($pkg) {
        # Combine dependencies and devDependencies for analysis
        $allDeps = @{}
        if ($pkg.dependencies) {
            $pkg.dependencies.PSObject.Properties | ForEach-Object {
                $allDeps[$_.Name] = $_.Value
            }
        }
        if ($pkg.devDependencies) {
            $pkg.devDependencies.PSObject.Properties | ForEach-Object {
                $allDeps[$_.Name] = $_.Value
            }
        }

        $result.dependencies = $allDeps

        # Detect Next.js
        if ($allDeps.ContainsKey("next")) {
            $result.projectType = "nextjs"
            $result.framework.name = "Next.js"
            $result.framework.version = $allDeps["next"]

            # Detect router type (App Router vs Pages Router)
            if (Test-Path (Join-Path $ProjectPath "app")) {
                $result.framework.router = "app"
                $result.confidence = 0.95
            }
            elseif (Test-Path (Join-Path $ProjectPath "pages")) {
                $result.framework.router = "pages"
                $result.confidence = 0.90
            }
            else {
                $result.framework.router = "unknown"
                $result.confidence = 0.85
            }
        }
        # Detect React + Vite
        elseif ($allDeps.ContainsKey("react") -and ($allDeps.ContainsKey("vite") -or $allDeps.ContainsKey("@vitejs/plugin-react"))) {
            $result.projectType = "react-vite"
            $result.framework.name = "React + Vite"
            $result.framework.version = $allDeps["react"]
            $result.confidence = 0.90
        }
        # Detect standalone React (CRA or other)
        elseif ($allDeps.ContainsKey("react") -and $allDeps.ContainsKey("react-scripts")) {
            $result.projectType = "react"
            $result.framework.name = "React (Create React App)"
            $result.framework.version = $allDeps["react"]
            $result.confidence = 0.85
        }
        # Detect standalone Vite
        elseif ($allDeps.ContainsKey("vite")) {
            $result.projectType = "vite"
            $result.framework.name = "Vite"
            $result.framework.version = $allDeps["vite"]
            $result.confidence = 0.70
        }
        # Fallback to generic Node.js project
        else {
            $result.projectType = "nodejs"
            $result.framework.name = "Node.js"
            $result.confidence = 0.60
        }

        # Detect test framework
        if ($allDeps.ContainsKey("vitest")) {
            $result.hasTests = $true
            $result.testFramework = "vitest"
        }
        elseif ($allDeps.ContainsKey("jest")) {
            $result.hasTests = $true
            $result.testFramework = "jest"
        }
        elseif ($allDeps.ContainsKey("@playwright/test")) {
            $result.hasTests = $true
            $result.testFramework = "playwright"
        }
        elseif (Test-PathPattern -Pattern "*test.js" -BasePath (Join-Path $ProjectPath "tests")) {
            $result.hasTests = $true
            $result.testFramework = "custom"
        }

        # Detect package manager
        if (Test-Path (Join-Path $ProjectPath "pnpm-lock.yaml")) {
            $result.packageManager = "pnpm"
        }
        elseif (Test-Path (Join-Path $ProjectPath "yarn.lock")) {
            $result.packageManager = "yarn"
        }
        elseif (Test-Path (Join-Path $ProjectPath "bun.lockb")) {
            $result.packageManager = "bun"
        }
        elseif (Test-Path (Join-Path $ProjectPath "package-lock.json")) {
            $result.packageManager = "npm"
        }
        else {
            $result.packageManager = "npm"  # Default
        }
    }
}

#endregion

#region Python Detection

$pyprojectPath = Join-Path $ProjectPath "pyproject.toml"
if (Test-Path $pyprojectPath) {
    $pyprojectContent = Get-Content $pyprojectPath -Raw

    # Detect FastAPI
    if ($pyprojectContent -match "fastapi") {
        $result.projectType = "fastapi"
        $result.framework.name = "FastAPI"
        $result.confidence = 0.90

        # Try to extract version
        if ($pyprojectContent -match 'fastapi\s*[=~><]+\s*["'']?([0-9.]+)') {
            $result.framework.version = $Matches[1]
        }
    }
    # Detect Django
    elseif ($pyprojectContent -match "django") {
        $result.projectType = "django"
        $result.framework.name = "Django"
        $result.confidence = 0.90

        # Try to extract version
        if ($pyprojectContent -match 'django\s*[=~><]+\s*["'']?([0-9.]+)') {
            $result.framework.version = $Matches[1]
        }

        # Detect Django apps directory
        if (Test-Path (Join-Path $ProjectPath "apps")) {
            $result.confidence = 0.95
        }
    }
    # Detect Flask
    elseif ($pyprojectContent -match "flask") {
        $result.projectType = "flask"
        $result.framework.name = "Flask"
        $result.confidence = 0.85
    }
    # Generic Python project
    else {
        $result.projectType = "python"
        $result.framework.name = "Python"
        $result.confidence = 0.70
    }

    # Detect test framework for Python
    if ($pyprojectContent -match "pytest") {
        $result.hasTests = $true
        $result.testFramework = "pytest"
    }
    elseif ($pyprojectContent -match "unittest") {
        $result.hasTests = $true
        $result.testFramework = "unittest"
    }

    # Detect package manager (uv, poetry, pip)
    if (Test-Path (Join-Path $ProjectPath "uv.lock")) {
        $result.packageManager = "uv"
    }
    elseif (Test-Path (Join-Path $ProjectPath "poetry.lock")) {
        $result.packageManager = "poetry"
    }
    elseif (Test-Path (Join-Path $ProjectPath "Pipfile.lock")) {
        $result.packageManager = "pipenv"
    }
    elseif (Test-Path (Join-Path $ProjectPath "requirements.txt")) {
        $result.packageManager = "pip"
    }
    else {
        $result.packageManager = "pip"  # Default
    }
}

#endregion

#region Go Detection

$goModPath = Join-Path $ProjectPath "go.mod"
if (Test-Path $goModPath) {
    $result.projectType = "go"
    $result.framework.name = "Go"
    $result.confidence = 0.85

    # Try to extract Go version
    $goModContent = Get-Content $goModPath -Raw
    if ($goModContent -match 'go\s+([0-9.]+)') {
        $result.framework.version = $Matches[1]
    }

    # Detect test files
    if (Test-PathPattern -Pattern "*_test.go") {
        $result.hasTests = $true
        $result.testFramework = "go test"
    }

    $result.packageManager = "go modules"
}

#endregion

#region Rust Detection (Bonus)

$cargoPath = Join-Path $ProjectPath "Cargo.toml"
if (Test-Path $cargoPath) {
    $result.projectType = "rust"
    $result.framework.name = "Rust"
    $result.confidence = 0.85

    # Detect tests
    if (Test-PathPattern -Pattern "tests") {
        $result.hasTests = $true
        $result.testFramework = "cargo test"
    }

    $result.packageManager = "cargo"
}

#endregion

#region Unknown Project Fallback

if ($result.projectType -eq "unknown") {
    # Try to infer from directory structure
    if (Test-Path (Join-Path $ProjectPath "src")) {
        $result.confidence = 0.30
    }

    # Check for common config files
    if (Test-Path (Join-Path $ProjectPath ".git")) {
        $result.confidence = [Math]::Max($result.confidence, 0.20)
    }
}

#endregion

# Output result as JSON
$result | ConvertTo-Json -Depth 10 -Compress
