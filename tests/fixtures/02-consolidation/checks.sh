#!/usr/bin/env bash
# Test 02 — consolidation: pattern detection
SANDBOX="$1"
fail=0
check() {
  if [ "$2" = "1" ]; then echo "  PASS — $1"
  else echo "  FAIL — $1"; fail=$((fail+1))
  fi
}

CONCEPTS_DIR="$SANDBOX/cortex/concepts"
created=0
matched_file=""
if [ -d "$CONCEPTS_DIR" ]; then
  while IFS= read -r f; do
    if grep -qi "pivocloud" "$f"; then
      created=1
      matched_file="$f"
      break
    fi
  done < <(find "$CONCEPTS_DIR" -maxdepth 1 -type f -name "*.md")
fi
check "A cortex/concepts/*.md page mentioning PivoCloud was created" "$created"

cited=0
if [ "$created" = "1" ]; then
  for d in 2026-04-29 2026-04-30 2026-05-01; do
    if grep -q "$d" "$matched_file"; then cited=1; break; fi
  done
fi
check "Cortex page cites at least one source hippocampus date" "$cited"

for d in 2026-04-29 2026-04-30 2026-05-01; do
  if [ -f "$SANDBOX/hippocampus/$d.md" ]; then check "hippocampus/$d.md still exists" 1
  else check "hippocampus/$d.md still exists" 0; fi
done

exit $fail
