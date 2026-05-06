#!/usr/bin/env pwsh
# test-init.ps1 — verify init-brain.ps1 transforms a template repo into a brain correctly.
# Deterministic. No LLM needed. Runs in seconds.

$ErrorActionPreference = "Continue"
$Here = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..")).Path
$Sandbox = Join-Path $env:TEMP "pivotex-init-test"
$script:fail = 0

function Check([string]$desc, [bool]$pass) {
    if ($pass) { Write-Host "  PASS — $desc" -ForegroundColor Green }
    else { Write-Host "  FAIL — $desc" -ForegroundColor Red; $script:fail++ }
}

Write-Host "Init smoke test"
Write-Host "  source repo : $Here"
Write-Host "  sandbox     : $Sandbox"
Write-Host ""

# --- Setup sandbox ---
Write-Host "[1/3] Copying repo to sandbox"
if (Test-Path $Sandbox) { Remove-Item -Recurse -Force $Sandbox }
New-Item -ItemType Directory -Path $Sandbox | Out-Null
# Copy everything except .git
Get-ChildItem $Here -Force | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
    Copy-Item -Recurse -Force -Path $_.FullName -Destination $Sandbox
}

# Capture expected post-init state
$expectedClaude = Get-Content (Join-Path $Sandbox "templates/brain-mode/CLAUDE.md") -Raw
$expectedReadmeHead = (Get-Content (Join-Path $Sandbox "templates/brain-mode/README.md") -TotalCount 1)

# --- Run init ---
Write-Host "[2/3] Running init-brain.ps1 in sandbox (auto-confirm)"
$initOutput = Join-Path $Sandbox ".init-output.log"
try {
    "y" | & pwsh -NoProfile -File (Join-Path $Sandbox "init-brain.ps1") 2>&1 | Out-File $initOutput
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: init-brain.ps1 exited non-zero. Output:" -ForegroundColor Red
        Get-Content $initOutput
        exit 1
    }
} catch {
    Write-Host "ERROR running init: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --- Verify ---
Write-Host "[3/3] Verifying post-init state"

Check "tests/ removed"            -pass (-not (Test-Path (Join-Path $Sandbox "tests")))
Check "docs/ removed"             -pass (-not (Test-Path (Join-Path $Sandbox "docs")))
Check "templates/ removed"        -pass (-not (Test-Path (Join-Path $Sandbox "templates")))
Check "CONTRIBUTING.md removed"   -pass (-not (Test-Path (Join-Path $Sandbox "CONTRIBUTING.md")))
Check "init-brain.sh self-deleted"  -pass (-not (Test-Path (Join-Path $Sandbox "init-brain.sh")))
Check "init-brain.ps1 self-deleted" -pass (-not (Test-Path (Join-Path $Sandbox "init-brain.ps1")))

$actualClaude = Get-Content (Join-Path $Sandbox "CLAUDE.md") -Raw
Check "Root CLAUDE.md is brain-mode version" -pass ($actualClaude -eq $expectedClaude)

$actualReadmeHead = Get-Content (Join-Path $Sandbox "README.md") -TotalCount 1
Check "README.md is brain-mode version" -pass ($actualReadmeHead -eq $expectedReadmeHead)

$brainContent = Get-Content (Join-Path $Sandbox "BRAIN.md") -Raw
Check "BRAIN.md Identity has sandbox path" -pass ($brainContent -match [regex]::Escape($Sandbox))
Check "BRAIN.md placeholder removed" -pass (-not ($brainContent -match "_absolute path of the folder containing this file"))

Check "BRAIN.md preserved"           -pass (Test-Path (Join-Path $Sandbox "BRAIN.md"))
Check "salience.md preserved"        -pass (Test-Path (Join-Path $Sandbox "salience.md"))
Check "hippocampus/ preserved"       -pass (Test-Path (Join-Path $Sandbox "hippocampus") -PathType Container)
Check "cortex/ preserved"            -pass (Test-Path (Join-Path $Sandbox "cortex") -PathType Container)
Check "limbic/ preserved"            -pass (Test-Path (Join-Path $Sandbox "limbic") -PathType Container)
Check "cerebellum/ preserved"        -pass (Test-Path (Join-Path $Sandbox "cerebellum") -PathType Container)
Check "sources/ preserved"           -pass (Test-Path (Join-Path $Sandbox "sources") -PathType Container)
Check "dreams/ preserved"            -pass (Test-Path (Join-Path $Sandbox "dreams") -PathType Container)
Check "stubs/ preserved"             -pass (Test-Path (Join-Path $Sandbox "stubs") -PathType Container)

if (Test-Path (Join-Path $Sandbox ".git")) {
    Push-Location $Sandbox
    try {
        $count = & git rev-list --count HEAD 2>$null
        Check "Git: exactly one commit (got $count)" -pass ($count -eq "1")
        $msg = & git log -1 --pretty=%s 2>$null
        Check "Git: commit message is 'Initial brain commit' (got '$msg')" -pass ($msg -eq "Initial brain commit")
    } finally {
        Pop-Location
    }
} else {
    Check "Git: .git directory exists after init" -pass $false
}

# --- Cleanup ---
Write-Host ""
if ($script:fail -eq 0) {
    Remove-Item -Recurse -Force $Sandbox
    Write-Host "PASS — init-brain.ps1 works correctly" -ForegroundColor Green
} else {
    Write-Host "FAIL — $($script:fail) assertion(s) failed." -ForegroundColor Red
    Write-Host "Sandbox preserved for inspection: $Sandbox"
}
exit $script:fail
