#!/usr/bin/env pwsh
# Test 03 — source citation: ingest produces cited cortex pages
param([Parameter(Mandatory=$true)][string]$Sandbox)

$fail = 0
function Check([string]$desc, [bool]$pass) {
    if ($pass) { Write-Host "  PASS — $desc" -ForegroundColor Green }
    else { Write-Host "  FAIL — $desc" -ForegroundColor Red; $script:fail++ }
}

# Source must be unchanged
$sourceFile = Join-Path $Sandbox "sources\2026-05-01_llm-wiki.md"
$sourceExists = Test-Path $sourceFile
Check "Source file still exists" $sourceExists

if ($sourceExists) {
    $sourceContent = Get-Content $sourceFile -Raw
    $sourceUntouched = $sourceContent -match "Stop re-deriving, start compiling"
    Check "Source content untouched (immutability)" $sourceUntouched
}

# A new cortex page must exist mentioning the LLM Wiki
$cortexConcepts = Join-Path $Sandbox "cortex\concepts"
$cortexEntities = Join-Path $Sandbox "cortex\entities"
$cortexPages = @()
foreach ($dir in @($cortexConcepts, $cortexEntities)) {
    if (Test-Path $dir) {
        $cortexPages += Get-ChildItem $dir -File -Filter "*.md" -Recurse
    }
}

$created = $false
$cited = $false
foreach ($p in $cortexPages) {
    $content = Get-Content $p.FullName -Raw
    if ($content -match "(?i)(LLM wiki|wiki pattern|knowledge base)") {
        $created = $true
        if ($content -match [regex]::Escape("sources/2026-05-01_llm-wiki.md")) {
            $cited = $true
            break
        }
    }
}

Check "A cortex page about the LLM Wiki was created" $created
Check "Cortex page cites the source: '(see sources/2026-05-01_llm-wiki.md)' or similar" $cited

exit $fail
