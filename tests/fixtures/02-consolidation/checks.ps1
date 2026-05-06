#!/usr/bin/env pwsh
# Test 02 — consolidation: pattern detection
param([Parameter(Mandatory=$true)][string]$Sandbox)

$fail = 0
function Check([string]$desc, [bool]$pass) {
    if ($pass) { Write-Host "  PASS — $desc" -ForegroundColor Green }
    else { Write-Host "  FAIL — $desc" -ForegroundColor Red; $script:fail++ }
}

# A new cortex page about PivoCloud-deployment must exist somewhere under cortex/concepts/
$cortexConcepts = Join-Path $Sandbox "cortex\concepts"
$created = $false
$pageContent = ""
if (Test-Path $cortexConcepts) {
    $candidates = Get-ChildItem $cortexConcepts -File -Filter "*.md" | Where-Object {
        (Get-Content $_.FullName -Raw) -match "(?i)pivocloud"
    }
    if ($candidates.Count -ge 1) {
        $created = $true
        $pageContent = Get-Content $candidates[0].FullName -Raw
    }
}
Check "A cortex/concepts/*.md page mentioning PivoCloud was created" $created

# It should reference at least one of the seeded hippocampus dates
$hasCitation = $false
if ($created) {
    foreach ($d in @("2026-04-29", "2026-04-30", "2026-05-01")) {
        if ($pageContent -match $d) { $hasCitation = $true; break }
    }
}
Check "Cortex page cites at least one source hippocampus date" $hasCitation

# Original hippocampus entries must remain untouched
foreach ($d in @("2026-04-29", "2026-04-30", "2026-05-01")) {
    $f = Join-Path $Sandbox "hippocampus\$d.md"
    Check "hippocampus/$d.md still exists" (Test-Path $f)
}

exit $fail
