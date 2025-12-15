#!/usr/bin/env node

/**
 * CLAUDE.md Auto-Init: Command Handler
 *
 * Entry point for the /init-claude slash command.
 * Orchestrates the PowerShell pipeline: scanner → selector → gather → generator → validator → writer
 *
 * @author Claude Code Auto-Init System
 * @version 2.0.0
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Configuration
const SCRIPTS_DIR = path.join(__dirname, '..', 'scripts', 'auto-init');
const isWindows = process.platform === 'win32';

// Script chain (in execution order)
const SCRIPT_CHAIN = [
  'scanner.ps1',
  'selector.ps1',
  'gather.ps1',
  'generator.ps1',
  'validator.ps1',
  'writer.ps1'
];

/**
 * Display banner
 */
function displayBanner() {
  console.log('\n╔═══════════════════════════════════════════════════════╗');
  console.log('║     CLAUDE.md Auto-Initialization System v2.0         ║');
  console.log('╚═══════════════════════════════════════════════════════╝\n');
}

/**
 * Check if PowerShell is available
 */
function checkPowerShell() {
  try {
    execSync('powershell.exe -Command "Write-Host test"', {
      stdio: 'ignore',
      timeout: 5000
    });
    return true;
  } catch (error) {
    console.error('❌ PowerShell not found or not accessible');
    console.error('   This system requires PowerShell 5.1+ or PowerShell 7+');
    return false;
  }
}

/**
 * Check if all required scripts exist
 */
function checkScripts() {
  const missingScripts = [];

  for (const script of SCRIPT_CHAIN) {
    const scriptPath = path.join(SCRIPTS_DIR, script);
    if (!fs.existsSync(scriptPath)) {
      missingScripts.push(script);
    }
  }

  if (missingScripts.length > 0) {
    console.error('❌ Missing required scripts:');
    missingScripts.forEach(script => console.error(`   - ${script}`));
    return false;
  }

  return true;
}

/**
 * Build PowerShell pipeline command
 */
function buildPipelineCommand() {
  const commands = SCRIPT_CHAIN.map((script, index) => {
    const scriptPath = path.join(SCRIPTS_DIR, script);

    if (index === 0) {
      // First script: direct execution
      return `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${scriptPath}"`;
    } else {
      // Subsequent scripts: pipe input
      return `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$input | & '${scriptPath}'"`;
    }
  });

  return commands.join(' | ');
}

/**
 * Run the PowerShell pipeline
 */
function runPipeline() {
  const pipeline = buildPipelineCommand();

  console.log('🔍 Scanning project...\n');

  try {
    const result = execSync(pipeline, {
      cwd: process.cwd(),
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'inherit'],  // Inherit stderr for user prompts
      timeout: 120000  // 2 minute timeout
    });

    // Parse final result
    const finalResult = JSON.parse(result.trim());

    // Display success summary
    if (finalResult.success) {
      console.log('\n✅ Success! Generated files:\n');

      finalResult.filesWritten.forEach(file => {
        console.log(`   📄 ${file}`);
      });

      if (finalResult.backups && finalResult.backups.length > 0) {
        console.log('\n📦 Backups created:');
        finalResult.backups.forEach(backup => {
          console.log(`   🔒 ${backup}`);
        });
      }

      if (finalResult.warnings && finalResult.warnings.length > 0) {
        console.log('\n⚠️  Warnings:');
        finalResult.warnings.forEach(warning => {
          console.log(`   ⚠️  ${warning}`);
        });
      }

      if (finalResult.gitignoreUpdated) {
        console.log('\n✨ Updated .gitignore with backup patterns');
      }

      console.log('\n📖 Next steps:');
      console.log('   1. Review generated files');
      console.log('   2. Customize as needed');
      console.log('   3. Commit to version control');
      console.log('');

      return 0;
    } else {
      console.error('\n❌ Generation failed');

      if (finalResult.errors && finalResult.errors.length > 0) {
        console.error('\nErrors:');
        finalResult.errors.forEach(error => {
          console.error(`   ❌ ${error}`);
        });
      }

      return 1;
    }
  } catch (error) {
    console.error('\n❌ Pipeline execution failed');

    if (error.message) {
      console.error(`\nError: ${error.message}`);
    }

    if (error.stderr) {
      console.error(`\nDetails: ${error.stderr}`);
    }

    console.error('\nTroubleshooting:');
    console.error('   1. Ensure PowerShell 5.1+ or 7+ is installed');
    console.error('   2. Check that all scripts exist in scripts/ directory');
    console.error('   3. Verify you have read/write permissions in this directory');
    console.error('   4. Try running scripts manually: .\\scripts\\scanner.ps1');

    return 1;
  }
}

/**
 * Main execution
 */
function main() {
  displayBanner();

  // Pre-flight checks
  if (!checkPowerShell()) {
    process.exit(1);
  }

  if (!checkScripts()) {
    console.error('\nPlease ensure the Auto-Init system is properly installed.');
    process.exit(1);
  }

  // Run pipeline
  const exitCode = runPipeline();

  process.exit(exitCode);
}

// Execute
if (require.main === module) {
  main();
}

module.exports = { main };
