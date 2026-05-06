#!/usr/bin/env pwsh
# update-brain.ps1 — deterministic phase of /pivotex-update.
# Handles all git operations. Run this first, then let the agent do the BRAIN.md merge.

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================================="
Write-Host " PIVOTEX protocol update — deterministic phase"
Write-Host "========================================================="
Write-Host ""

# 1. Working-tree check
$status = git -C $Here status --porcelain
if ($status) {
    Write-Host "ERROR: Uncommitted changes detected. Stash or commit them first." -ForegroundColor Red
    exit 1
}

# 2. Ensure upstream remote
$remoteUrl = git -C $Here remote get-url upstream 2>$null
if (-not $remoteUrl) {
    git -C $Here remote add upstream https://github.com/PivoSide/pivotex.git
    Write-Host "-> Added upstream remote."
}

# 3. Fetch
Write-Host "-> Fetching upstream/main..."
git -C $Here fetch upstream main -q

# 4. Version comparison
$localVer = (Get-Content (Join-Path $Here "VERSION") -ErrorAction SilentlyContinue) -join "" | ForEach-Object { $_.Trim() }
if (-not $localVer) { $localVer = "unknown" }
$upstreamVer = (git -C $Here show upstream/main:VERSION 2>$null) -join "" | ForEach-Object { $_.Trim() }
if (-not $upstreamVer) { $upstreamVer = "unknown" }

Write-Host "-> Local:    $localVer"
Write-Host "-> Upstream: $upstreamVer"

if ($localVer -eq $upstreamVer) {
    Write-Host "-> Already on latest version."
    $force = Read-Host "Continue anyway (re-apply protocol files)? [y/N]"
    if ($force -notmatch '^[yY]') { Write-Host "Nothing to do."; exit 0 }
}

# 5. Show changed protocol files
Write-Host ""
Write-Host "-> Protocol files that will change:"
git -C $Here diff --name-only upstream/main -- CLAUDE.md GEMINI.md .cursorrules AGENTS.md stubs/ VERSION
Write-Host ""

$ans = Read-Host "Apply update? [y/N]"
if ($ans -notmatch '^[yY]') { Write-Host "Cancelled."; exit 0 }

# 6. Checkout protocol files (user data never touched)
Write-Host "-> Updating protocol files..."
git -C $Here checkout upstream/main -- CLAUDE.md GEMINI.md .cursorrules AGENTS.md stubs/ VERSION

# 7. Install Claude Code slash commands
$claudeCommandsSrc = Join-Path $Here "stubs\claude-commands"
if (Test-Path $claudeCommandsSrc) {
    Write-Host "-> Installing Claude Code slash commands..."
    $dest = Join-Path $Here ".claude\commands"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem "$claudeCommandsSrc\*.md" | ForEach-Object {
        Copy-Item -Force $_.FullName $dest
    }
}

# 8. Stage everything except BRAIN.md (agent handles that)
git -C $Here add --all -- ':!BRAIN.md'

Write-Host ""
Write-Host "========================================================="
Write-Host " Deterministic phase complete."
Write-Host "========================================================="
Write-Host ""
Write-Host "Now ask your agent to complete the update:"
Write-Host "  'Complete the BRAIN.md merge for /pivotex-update'"
Write-Host ""
Write-Host "The agent will merge upstream protocol into BRAIN.md while"
Write-Host "preserving your Identity block, then commit."
