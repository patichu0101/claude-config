# PowerShell Script API Reference

API documentation for the Auto-Init PowerShell pipeline scripts.

---

## Pipeline Overview

```
scanner.ps1 → selector.ps1 → gather.ps1 → generator.ps1 → validator.ps1 → writer.ps1
```

Each script communicates via JSON stdin/stdout.

---

## scanner.ps1

**Purpose:** Detect project framework and metadata

**Input:** None (scans current directory)

**Output:** JSON object with project information

**Schema:**
```json
{
  "framework": {
    "name": "string",
    "version": "string",
    "router": "string"
  },
  "projectType": "string",
  "projectPath": "string",
  "confidence": "number (0-100)",
  "dependencies": "object",
  "packageManager": "string",
  "testFramework": "string",
  "hasTests": "boolean",
  "scannedAt": "string (ISO date)"
}
```

---

## selector.ps1

**Purpose:** Select template and build variable map

**Input:** JSON from scanner.ps1

**Output:** JSON with template path and variables

**Schema:**
```json
{
  "templatePath": "string",
  "templateName": "string",
  "variables": "object",
  "scanResult": "object (pass-through from scanner)"
}
```

---

## generator.ps1

**Purpose:** Replace placeholders in template

**Input:** JSON from selector.ps1

**Output:** JSON with generated content

---

## validator.ps1

**Purpose:** Security validation

**Input:** JSON from generator.ps1

**Output:** JSON with validation results

---

## writer.ps1

**Purpose:** Safely write files with backups

**Input:** JSON from validator.ps1

**Output:** JSON with write results

**Schema:**
```json
{
  "success": "boolean",
  "filesWritten": ["array of paths"],
  "backups": ["array of backup paths"],
  "errors": ["array of error messages"],
  "warnings": ["array of warnings"]
}
```

---

See `.claude/templates/auto-init/README.md` for detailed customization guide.
