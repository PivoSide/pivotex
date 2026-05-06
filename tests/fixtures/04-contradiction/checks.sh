#!/usr/bin/env bash
# Test 04 — contradiction handling
SANDBOX="$1"
fail=0
check() {
  if [ "$2" = "1" ]; then echo "  PASS — $1"
  else echo "  FAIL — $1"; fail=$((fail+1))
  fi
}

SRC="$SANDBOX/sources/2026-05-01_lyon-claim.md"
[ -f "$SRC" ] && check "Source file still exists" 1 || check "Source file still exists" 0
if [ -f "$SRC" ]; then
  if grep -q "intentionally wrong" "$SRC"; then check "Source content untouched (immutability)" 1
  else check "Source content untouched (immutability)" 0; fi
fi

FRANCE="$SANDBOX/cortex/concepts/france.md"
if [ -f "$FRANCE" ]; then
  check "cortex/concepts/france.md still exists" 1
  grep -q "Paris" "$FRANCE" && check "France page still mentions Paris (original retained)" 1 || check "France page still mentions Paris (original retained)" 0
  grep -q "Lyon" "$FRANCE" && check "France page now mentions Lyon (new claim added)" 1 || check "France page now mentions Lyon (new claim added)" 0
  grep -q "## Conflicts" "$FRANCE" && check "France page has a '## Conflicts' section" 1 || check "France page has a '## Conflicts' section" 0
  grep -qF "sources/2026-05-01_lyon-claim.md" "$FRANCE" && check "France page cites the new source" 1 || check "France page cites the new source" 0
else
  check "cortex/concepts/france.md still exists" 0
fi

exit $fail
