#!/usr/bin/env bash
# Test 03 — source citation
SANDBOX="$1"
fail=0
check() {
  if [ "$2" = "1" ]; then echo "  PASS — $1"
  else echo "  FAIL — $1"; fail=$((fail+1))
  fi
}

SRC="$SANDBOX/sources/2026-05-01_llm-wiki.md"
[ -f "$SRC" ] && check "Source file still exists" 1 || check "Source file still exists" 0
if [ -f "$SRC" ]; then
  if grep -q "Stop re-deriving, start compiling" "$SRC"; then
    check "Source content untouched (immutability)" 1
  else
    check "Source content untouched (immutability)" 0
  fi
fi

created=0
cited=0
matched=""
if [ -d "$SANDBOX/cortex" ]; then
  while IFS= read -r p; do
    if grep -qiE "(LLM wiki|wiki pattern|knowledge base)" "$p"; then
      created=1
      matched="$p"
      if grep -qF "sources/2026-05-01_llm-wiki.md" "$p"; then
        cited=1
        break
      fi
    fi
  done < <(find "$SANDBOX/cortex" -type f -name "*.md")
fi

check "A cortex page about the LLM Wiki was created" "$created"
check "Cortex page cites the source: 'sources/2026-05-01_llm-wiki.md'" "$cited"

exit $fail
