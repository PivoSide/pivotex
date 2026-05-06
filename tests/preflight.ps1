#!/usr/bin/env pwsh
# preflight.ps1 — static integrity checks for the PIVOTEX template.
# No LLM, no agent. Catches structural breakage in milliseconds.

$ErrorActionPreference = "Continue"
$Here = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..")).Path
$script:fail = 0

function Check([string]$desc, [bool]$pass) {
    if ($pass) { Write-Host "  PASS  — $desc" -ForegroundColor Green }
    else { Write-Host "  FAIL  — $desc" -ForegroundColor Red; $script:fail++ }
}
function Skip([string]$desc) { Write-Host "  SKIP  — $desc" -ForegroundColor Yellow }

Write-Host "PIVOTEX preflight (root: $Here)"
Write-Host ""

# --- 1. Required top-level files ---
Write-Host "[1] Top-level files"
$topFiles = @('BRAIN.md','README.md','CLAUDE.md','.cursorrules','AGENTS.md','LICENSE','VERSION',
              'init-brain.sh','init-brain.ps1','salience.md','CONTRIBUTING.md','.gitignore')
foreach ($f in $topFiles) {
    Check $f -pass (Test-Path (Join-Path $Here $f))
}

# --- 2. Required folders ---
Write-Host ""
Write-Host "[2] Required folders"
$folders = @('hippocampus','cortex','cerebellum','limbic','sources','dreams','stubs','templates','tests','docs')
foreach ($d in $folders) {
    Check "$d/" -pass (Test-Path (Join-Path $Here $d) -PathType Container)
}

# --- 3. Brain-mode templates ---
Write-Host ""
Write-Host "[3] Brain-mode templates (used by init)"
foreach ($f in @('CLAUDE.md','.cursorrules','AGENTS.md','README.md')) {
    Check "templates/brain-mode/$f" -pass (Test-Path (Join-Path $Here "templates/brain-mode/$f"))
}

# --- 4. Cross-project stubs ---
Write-Host ""
Write-Host "[4] Cross-project stubs"
foreach ($f in @('CLAUDE.md','.cursorrules','AGENTS.md','system-prompt.txt')) {
    Check "stubs/$f" -pass (Test-Path (Join-Path $Here "stubs/$f"))
}

# --- 5. Test fixtures cross-platform parity ---
Write-Host ""
Write-Host "[5] Test fixtures cross-platform parity"
$fixturesDir = Join-Path $Here "tests/fixtures"
if (Test-Path $fixturesDir) {
    foreach ($fixture in (Get-ChildItem $fixturesDir -Directory)) {
        Check "$($fixture.Name) has checks.ps1" -pass (Test-Path (Join-Path $fixture.FullName "checks.ps1"))
        Check "$($fixture.Name) has checks.sh"  -pass (Test-Path (Join-Path $fixture.FullName "checks.sh"))
        Check "$($fixture.Name) has seed/"      -pass (Test-Path (Join-Path $fixture.FullName "seed") -PathType Container)
    }
}

# --- 6. Init scripts parse ---
Write-Host ""
Write-Host "[6] Init scripts parse"
$bashAvail = Get-Command bash -ErrorAction SilentlyContinue
if ($bashAvail) {
    & bash -n (Join-Path $Here "init-brain.sh") 2>$null
    Check "init-brain.sh parses (bash -n)" -pass ($LASTEXITCODE -eq 0)
} else {
    Skip "init-brain.sh parse (bash not installed)"
}
try {
    [scriptblock]::Create((Get-Content -Raw (Join-Path $Here "init-brain.ps1"))) | Out-Null
    Check "init-brain.ps1 parses (PowerShell)" -pass $true
} catch {
    Check "init-brain.ps1 parses (PowerShell): $($_.Exception.Message)" -pass $false
}

# --- 7. Template state invariants ---
Write-Host ""
Write-Host "[7] Template state invariants"
$brain = Get-Content (Join-Path $Here "BRAIN.md") -Raw
Check "BRAIN.md has Identity placeholder (template, not inited)" -pass ($brain -match "_absolute path of the folder containing this file; filled during Onboarding_")
$user = Get-Content (Join-Path $Here "limbic/user.md") -Raw
Check "limbic/user.md is needs-setup (template, not onboarded)" -pass ($user -match "(?m)^Status: needs-setup")

# --- 8. No personal-data leakage ---
Write-Host ""
Write-Host "[8] No personal-data leakage in template"
$leaked = $false
$searchDirs = Get-ChildItem $Here -Recurse -File -Force | Where-Object {
    $_.FullName -notmatch "[\\/]\.git[\\/]" -and $_.FullName -notmatch "[\\/]tests[\\/]"
}
$personalPatterns = @('salim\.lemdani', '@gmail\.com', '@yahoo\.com', '@hotmail\.com', '@outlook\.com',
                       'C:\\\\Users\\\\salim')
foreach ($file in $searchDirs) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        foreach ($pat in $personalPatterns) {
            if ($content -match $pat) { $leaked = $true; break }
        }
        if ($leaked) { break }
    } catch { }
}
Check "No personal emails or hardcoded user paths" -pass (-not $leaked)

# --- 9. BRAIN.md cross-references resolve ---
Write-Host ""
Write-Host "[9] BRAIN.md cross-references resolve"
$refs = @('limbic/self.md','limbic/user.md','salience.md','hippocampus/_template.md','templates/brain-mode','stubs')
foreach ($ref in $refs) {
    if ($brain -match [regex]::Escape($ref)) {
        Check "BRAIN.md ref -> $ref" -pass (Test-Path (Join-Path $Here $ref))
    }
}

# --- 10. Operation parity ---
Write-Host ""
Write-Host "[10] Operation parity (BRAIN.md vs README.md)"
$readme = Get-Content (Join-Path $Here "README.md") -Raw
foreach ($op in @('/pivotex-ingest','/pivotex-consolidate','/pivotex-lint','/pivotex-dream','/pivotex-forget','/pivotex-update')) {
    $inBrain  = $brain  -match [regex]::Escape($op)
    $inReadme = $readme -match [regex]::Escape($op)
    Check "$op declared in both (BRAIN=$inBrain README=$inReadme)" -pass ($inBrain -and $inReadme)
}

# --- 11. Length conventions ---
Write-Host ""
Write-Host "[11] File length conventions"
$soft = 250
$hard = 400
$alwaysSingle = @('BRAIN.md','README.md','CLAUDE.md','.cursorrules','AGENTS.md','LICENSE','salience.md')
$mdFiles = Get-ChildItem $Here -Recurse -Filter "*.md" -File | Where-Object {
    $_.FullName -notmatch "[\\/]\.git[\\/]" -and $_.FullName -notmatch "[\\/]tests[\\/]fixtures[\\/]"
}
foreach ($f in $mdFiles) {
    $lines = (Get-Content $f.FullName | Measure-Object -Line).Lines
    $rel = $f.FullName.Substring($Here.Length).TrimStart('\','/')
    $isSingle = $alwaysSingle -contains $f.Name
    if ($lines -gt $hard) {
        if ($isSingle) {
            Check "$rel <= $hard lines (always-single, $lines)" -pass $false
        } else {
            Check "$rel <= $hard lines (splittable, $lines — will auto-split)" -pass $false
        }
    } elseif ($lines -gt $soft) {
        $content = Get-Content $f.FullName -Raw
        $hasSummary = $content -match "(?m)^## Summary"
        $hasOutline = $content -match "(?m)^## (Outline|Table of contents)"
        if ($hasSummary -and $hasOutline) {
            Check "$rel ($lines lines) has ## Summary + ## Outline" -pass $true
        } else {
            Check "$rel ($lines lines, >$soft) needs ## Summary + ## Outline" -pass $false
        }
    }
}

# --- Summary ---
Write-Host ""
if ($script:fail -eq 0) {
    Write-Host "PASS — all preflight checks" -ForegroundColor Green
} else {
    Write-Host "FAIL — $($script:fail) check(s) failed" -ForegroundColor Red
}
exit $script:fail
