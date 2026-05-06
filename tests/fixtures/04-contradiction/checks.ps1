#!/usr/bin/env pwsh
# Test 04 — contradiction handling
param([Parameter(Mandatory=$true)][string]$Sandbox)

$fail = 0
function Check([string]$desc, [bool]$pass) {
    if ($pass) { Write-Host "  PASS — $desc" -ForegroundColor Green }
    else { Write-Host "  FAIL — $desc" -ForegroundColor Red; $script:fail++ }
}

# Source must be unchanged
$src = Join-Path $Sandbox "sources\2026-05-01_lyon-claim.md"
$srcExists = Test-Path $src
Check "Source file still exists" $srcExists
if ($srcExists) {
    $srcContent = Get-Content $src -Raw
    Check "Source content untouched (immutability)" ($srcContent -match "intentionally wrong")
}

# France page must still exist
$france = Join-Path $Sandbox "cortex\concepts\france.md"
$franceExists = Test-Path $france
Check "cortex/concepts/france.md still exists" $franceExists

if ($franceExists) {
    $content = Get-Content $france -Raw
    Check "France page still mentions Paris (original claim retained)" ($content -match "Paris")
    Check "France page now mentions Lyon (new claim added)" ($content -match "Lyon")
    Check "France page has a '## Conflicts' section" ($content -match "## Conflicts")
    Check "France page cites the new source for Lyon" ($content -match [regex]::Escape("sources/2026-05-01_lyon-claim.md"))
}

exit $fail
