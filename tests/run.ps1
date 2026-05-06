#!/usr/bin/env pwsh
# PIVOTEX test runner (Windows / PowerShell)
# Usage: pwsh tests/run.ps1 -TestId 02-consolidation

param(
    [Parameter(Mandatory=$true)]
    [string]$TestId
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$fixtureDir = Join-Path $here "fixtures\$TestId"

if (-not (Test-Path $fixtureDir)) {
    Write-Host "No fixture for test '$TestId' at $fixtureDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available tests with fixtures:"
    Get-ChildItem (Join-Path $here "fixtures") -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host ""
    Write-Host "See tests/cognitive-memory-tests.md for the full catalog (some are spec-only)."
    exit 1
}

$sandbox = Join-Path $env:TEMP "pivotex-test-$TestId"
if (Test-Path $sandbox) { Remove-Item -Recurse -Force $sandbox }
New-Item -ItemType Directory -Path $sandbox | Out-Null

$seedDir = Join-Path $fixtureDir "seed"
if (Test-Path $seedDir) {
    Copy-Item -Recurse -Force "$seedDir\*" $sandbox
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Sandbox brain ready: $sandbox" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open tests/cognitive-memory-tests.md and find test '$TestId'."
Write-Host "Point your agent at:"
Write-Host "  $sandbox"
Write-Host ""
Write-Host "Perform the Action specified in the test."
Write-Host ""
Read-Host "Press Enter when the agent has finished"

$checks = Join-Path $fixtureDir "checks.ps1"
if (-not (Test-Path $checks)) {
    Write-Host "No checks.ps1 in fixture; cannot verify deterministically." -ForegroundColor Yellow
    exit 2
}

Write-Host ""
Write-Host "Running assertions..."
& $checks $sandbox
$exit = $LASTEXITCODE
Write-Host ""
if ($exit -eq 0) {
    Write-Host "PASS — $TestId" -ForegroundColor Green
} else {
    Write-Host "FAIL — $TestId (exit $exit)" -ForegroundColor Red
}
exit $exit
