#!/usr/bin/env pwsh
# init-brain.ps1 — convert this template into a personal PIVOTEX brain.
# One-time use. Self-deletes on success.
#
# What this does (no prompts — fully deterministic):
#   - Replaces root CLAUDE.md, .cursorrules, AGENTS.md, README.md with brain-mode versions
#   - Sets the brain root path in BRAIN.md
#   - Removes ALL maintainer-only artifacts: tests\, docs\, CONTRIBUTING.md, templates\
#   - Resets git history to a single "Initial brain commit"
#   - Removes init-brain.sh and init-brain.ps1

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================================="
Write-Host " PIVOTEX brain activation"
Write-Host "========================================================="
Write-Host ""
Write-Host "This will convert this folder into your personal PIVOTEX brain."
Write-Host ""
Write-Host "This action will:"
Write-Host "  - Replace CLAUDE.md, .cursorrules, AGENTS.md, README.md with brain-mode versions"
Write-Host "  - Set the brain root path in BRAIN.md"
Write-Host "  - REMOVE: tests\, docs\, CONTRIBUTING.md, templates\, init-brain.{sh,ps1}"
Write-Host "  - RESET git history (single 'Initial brain commit')"
Write-Host ""
Write-Host "This is one-time and irreversible (unless you re-clone)."
Write-Host ""

$ans = Read-Host "Continue? [y/N]"
if ($ans -notmatch '^[yY]') {
    Write-Host "Cancelled."
    exit 0
}

$brainModeDir = Join-Path $Here "templates\brain-mode"
if (-not (Test-Path $brainModeDir)) {
    Write-Host "ERROR: templates\brain-mode\ not found." -ForegroundColor Red
    Write-Host "Either this script has already run, or the template was modified."
    exit 1
}

Write-Host ""
Write-Host "-> Replacing root agent-config files with brain-mode versions..."
Copy-Item -Force (Join-Path $brainModeDir "CLAUDE.md")    (Join-Path $Here "CLAUDE.md")
Copy-Item -Force (Join-Path $brainModeDir ".cursorrules") (Join-Path $Here ".cursorrules")
Copy-Item -Force (Join-Path $brainModeDir "AGENTS.md")    (Join-Path $Here "AGENTS.md")
Copy-Item -Force (Join-Path $brainModeDir "README.md")    (Join-Path $Here "README.md")

Write-Host "-> Setting brain root path in BRAIN.md..."
$brainPath = Join-Path $Here "BRAIN.md"
$content = Get-Content $brainPath -Raw
$placeholder = "_absolute path of the folder containing this file; filled during Onboarding_"
$replacement = "``$Here``"
$content = $content -replace [regex]::Escape($placeholder), $replacement
Set-Content -Path $brainPath -Value $content -NoNewline

Write-Host "-> Removing maintainer-only artifacts..."
Remove-Item -Recurse -Force (Join-Path $Here "templates") -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Here "tests")     -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Here "docs")      -ErrorAction SilentlyContinue
Remove-Item -Force (Join-Path $Here "CONTRIBUTING.md")    -ErrorAction SilentlyContinue
Remove-Item -Force (Join-Path $Here "CHANGELOG.md")       -ErrorAction SilentlyContinue

Write-Host "-> Resetting git history..."
Remove-Item -Recurse -Force (Join-Path $Here ".git") -ErrorAction SilentlyContinue
Push-Location $Here
try {
    git init -q
    git add -A
    git -c user.email=brain@local -c user.name="PIVOTEX brain" commit -q -m "Initial brain commit" 2>$null
} finally {
    Pop-Location
}

Remove-Item -Force (Join-Path $Here "init-brain.sh") -ErrorAction SilentlyContinue
Remove-Item -Force (Join-Path $Here "init-brain.ps1") -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================="
Write-Host " Activation complete."
Write-Host "========================================================="
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open Claude Code (or Cursor / Codex) in this folder."
Write-Host "  2. Say hi. The agent will run the Onboarding flow defined in BRAIN.md."
Write-Host ""
