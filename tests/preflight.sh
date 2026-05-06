#!/usr/bin/env bash
# preflight.sh — static integrity checks for the PIVOTEX template.
# No LLM, no agent. Catches structural breakage in milliseconds.

set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

check() {
  if [ "$2" = "1" ]; then echo "  PASS  — $1"
  else echo "  FAIL  — $1"; fail=$((fail+1))
  fi
}
skip() { echo "  SKIP  — $1"; }

echo "PIVOTEX preflight (root: $HERE)"
echo

# --- 1. Required top-level files ---
echo "[1] Top-level files"
for f in BRAIN.md README.md CLAUDE.md .cursorrules AGENTS.md LICENSE VERSION \
         init-brain.sh init-brain.ps1 salience.md CONTRIBUTING.md .gitignore; do
  [ -f "$HERE/$f" ] && check "$f" 1 || check "$f" 0
done

# --- 2. Required folders ---
echo
echo "[2] Required folders"
for d in hippocampus cortex cerebellum limbic sources dreams stubs templates tests docs; do
  [ -d "$HERE/$d" ] && check "$d/" 1 || check "$d/" 0
done

# --- 3. Brain-mode templates ---
echo
echo "[3] Brain-mode templates (used by init)"
for f in CLAUDE.md .cursorrules AGENTS.md README.md; do
  [ -f "$HERE/templates/brain-mode/$f" ] && check "templates/brain-mode/$f" 1 || check "templates/brain-mode/$f" 0
done

# --- 4. Cross-project stubs ---
echo
echo "[4] Cross-project stubs"
for f in CLAUDE.md .cursorrules AGENTS.md system-prompt.txt; do
  [ -f "$HERE/stubs/$f" ] && check "stubs/$f" 1 || check "stubs/$f" 0
done

# --- 5. Test fixtures have both PS1 + SH checks ---
echo
echo "[5] Test fixtures cross-platform parity"
if [ -d "$HERE/tests/fixtures" ]; then
  for fixture in "$HERE/tests/fixtures"/*/; do
    [ -d "$fixture" ] || continue
    name=$(basename "$fixture")
    [ -f "$fixture/checks.ps1" ] && check "$name has checks.ps1" 1 || check "$name has checks.ps1" 0
    [ -f "$fixture/checks.sh" ]  && check "$name has checks.sh"  1 || check "$name has checks.sh"  0
    [ -d "$fixture/seed" ]       && check "$name has seed/"      1 || check "$name has seed/"      0
  done
fi

# --- 6. Init scripts parse ---
echo
echo "[6] Init scripts parse"
bash -n "$HERE/init-brain.sh" 2>/dev/null && check "init-brain.sh parses (bash -n)" 1 || check "init-brain.sh parses (bash -n)" 0
if command -v pwsh >/dev/null 2>&1; then
  if pwsh -NoProfile -Command "try { [scriptblock]::Create((Get-Content -Raw '$HERE/init-brain.ps1')) | Out-Null; exit 0 } catch { exit 1 }" >/dev/null 2>&1; then
    check "init-brain.ps1 parses (PowerShell)" 1
  else
    check "init-brain.ps1 parses (PowerShell)" 0
  fi
else
  skip "init-brain.ps1 parse (pwsh not installed)"
fi

# --- 7. Template state invariants ---
echo
echo "[7] Template state invariants"
if grep -q "_absolute path of the folder containing this file; filled during Onboarding_" "$HERE/BRAIN.md"; then
  check "BRAIN.md has Identity placeholder (template, not inited)" 1
else
  check "BRAIN.md has Identity placeholder (template, not inited)" 0
fi
if grep -q "^Status: needs-setup" "$HERE/limbic/user.md"; then
  check "limbic/user.md is needs-setup (template, not onboarded)" 1
else
  check "limbic/user.md is needs-setup (template, not onboarded)" 0
fi

# --- 8. No obvious personal-data leakage ---
echo
echo "[8] No personal-data leakage in template"
LEAKED=0
# Common patterns: real-looking emails, hardcoded user paths
if grep -rqE "(salim\.lemdani|@gmail\.com|@yahoo\.com|@hotmail\.com|@outlook\.com)" \
     "$HERE" --exclude-dir=.git --exclude-dir=tests --exclude-dir=node_modules 2>/dev/null; then
  LEAKED=1
fi
if grep -rq "C:\\\\Users\\\\salim" \
     "$HERE" --exclude-dir=.git --exclude-dir=tests 2>/dev/null; then
  LEAKED=1
fi
[ "$LEAKED" = "0" ] && check "No personal emails or hardcoded user paths" 1 || {
  check "No personal emails or hardcoded user paths" 0
  echo "       (run: grep -rE '(salim|@gmail)' . --exclude-dir=.git)"
}

# --- 9. Routing rules reference real regions ---
echo
echo "[9] BRAIN.md cross-references resolve"
for ref in "limbic/self.md" "limbic/user.md" "salience.md" "hippocampus/_template.md" "templates/brain-mode/" "stubs/"; do
  if grep -q "$ref" "$HERE/BRAIN.md" 2>/dev/null; then
    target="${ref%/}"
    if [ -e "$HERE/$target" ]; then
      check "BRAIN.md ref → $ref" 1
    else
      check "BRAIN.md ref → $ref (target missing)" 0
    fi
  fi
done

# --- 10. Operations declared in BRAIN.md match README ---
echo
echo "[10] Operation parity (BRAIN.md vs README.md)"
for op in /pivotex-ingest /pivotex-consolidate /pivotex-lint /pivotex-dream /pivotex-forget /pivotex-update; do
  in_brain=0; in_readme=0
  grep -q "\`$op" "$HERE/BRAIN.md" 2>/dev/null && in_brain=1
  grep -q "\`$op" "$HERE/README.md" 2>/dev/null && in_readme=1
  if [ "$in_brain" = "1" ] && [ "$in_readme" = "1" ]; then
    check "$op declared in both" 1
  else
    check "$op declared in both (BRAIN=$in_brain README=$in_readme)" 0
  fi
done

# --- 11. Length conventions (Length & decomposition rule) ---
echo
echo "[11] File length conventions"
SOFT=250
HARD=400
ALWAYS_SINGLE_REGEX='^\./(BRAIN\.md|README\.md|CLAUDE\.md|\.cursorrules|AGENTS\.md|LICENSE|salience\.md)$'
while IFS= read -r f; do
  lines=$(wc -l < "$f")
  rel="${f#$HERE/}"
  is_single=0
  if echo "./$rel" | grep -qE "$ALWAYS_SINGLE_REGEX"; then is_single=1; fi
  if [ "$lines" -gt "$HARD" ]; then
    if [ "$is_single" = "1" ]; then
      check "$rel ≤ $HARD lines (always-single, $lines)" 0
    else
      check "$rel ≤ $HARD lines (splittable, $lines — will auto-split)" 0
    fi
  elif [ "$lines" -gt "$SOFT" ]; then
    if grep -q "^## Summary" "$f" && grep -q "^## Outline\|^## Table of contents" "$f"; then
      check "$rel ($lines lines) has ## Summary + ## Outline" 1
    else
      check "$rel ($lines lines, >$SOFT) needs ## Summary + ## Outline" 0
    fi
  fi
done < <(find "$HERE" -name "*.md" -not -path "*/.git/*" -not -path "*/tests/fixtures/*")

# --- Summary ---
echo
if [ "$fail" = "0" ]; then
  echo "PASS — all preflight checks"
else
  echo "FAIL — $fail check(s) failed"
fi
exit $fail
