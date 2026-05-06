#!/usr/bin/env bash
# test-init.sh — verify init-brain.sh transforms a template repo into a brain correctly.
# Deterministic. No LLM needed. Runs in seconds.

set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SANDBOX="${TMPDIR:-/tmp}/pivotex-init-test"
fail=0

check() {
  if [ "$2" = "1" ]; then echo "  PASS — $1"
  else echo "  FAIL — $1"; fail=$((fail+1))
  fi
}

echo "Init smoke test"
echo "  source repo : $HERE"
echo "  sandbox     : $SANDBOX"
echo

# --- Setup sandbox ---
echo "[1/3] Copying repo to sandbox"
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"
# Copy everything except .git (init creates fresh)
(cd "$HERE" && tar --exclude='.git' --exclude="$(basename "$SANDBOX")" -cf - .) | (cd "$SANDBOX" && tar -xf -)

# Capture expected post-init state (read brain-mode templates BEFORE init wipes them)
EXPECTED_CLAUDE=$(cat "$SANDBOX/templates/brain-mode/CLAUDE.md")
EXPECTED_README_HEAD=$(head -1 "$SANDBOX/templates/brain-mode/README.md")

# --- Run init ---
echo "[2/3] Running init-brain.sh in sandbox (auto-confirm)"
if ! echo y | bash "$SANDBOX/init-brain.sh" > "$SANDBOX/.init-output.log" 2>&1; then
  echo "ERROR: init-brain.sh exited non-zero. Output:"
  cat "$SANDBOX/.init-output.log"
  exit 1
fi

# --- Verify ---
echo "[3/3] Verifying post-init state"

# Maintainer artifacts removed
[ ! -d "$SANDBOX/tests" ]            && check "tests/ removed"            1 || check "tests/ removed"            0
[ ! -d "$SANDBOX/docs" ]             && check "docs/ removed"             1 || check "docs/ removed"             0
[ ! -d "$SANDBOX/templates" ]        && check "templates/ removed"        1 || check "templates/ removed"        0
[ ! -f "$SANDBOX/CONTRIBUTING.md" ]  && check "CONTRIBUTING.md removed"   1 || check "CONTRIBUTING.md removed"   0
[ ! -f "$SANDBOX/init-brain.sh" ]    && check "init-brain.sh self-deleted"  1 || check "init-brain.sh self-deleted"  0
[ ! -f "$SANDBOX/init-brain.ps1" ]   && check "init-brain.ps1 self-deleted" 1 || check "init-brain.ps1 self-deleted" 0

# Brain-mode files at root
ACTUAL_CLAUDE=$(cat "$SANDBOX/CLAUDE.md")
[ "$ACTUAL_CLAUDE" = "$EXPECTED_CLAUDE" ] && check "Root CLAUDE.md is brain-mode version" 1 || check "Root CLAUDE.md is brain-mode version" 0

# README is brain-mode
ACTUAL_README_HEAD=$(head -1 "$SANDBOX/README.md")
[ "$ACTUAL_README_HEAD" = "$EXPECTED_README_HEAD" ] && check "README.md is brain-mode version" 1 || check "README.md is brain-mode version" 0

# BRAIN.md path filled
if grep -qF "$SANDBOX" "$SANDBOX/BRAIN.md"; then
  check "BRAIN.md Identity has sandbox path" 1
else
  check "BRAIN.md Identity has sandbox path" 0
fi
if grep -q "_absolute path of the folder containing this file" "$SANDBOX/BRAIN.md"; then
  check "BRAIN.md placeholder removed" 0
else
  check "BRAIN.md placeholder removed" 1
fi

# Other regions still intact
[ -f "$SANDBOX/BRAIN.md" ]        && check "BRAIN.md preserved"           1 || check "BRAIN.md preserved"           0
[ -f "$SANDBOX/salience.md" ]     && check "salience.md preserved"        1 || check "salience.md preserved"        0
[ -d "$SANDBOX/hippocampus" ]     && check "hippocampus/ preserved"       1 || check "hippocampus/ preserved"       0
[ -d "$SANDBOX/cortex" ]          && check "cortex/ preserved"            1 || check "cortex/ preserved"            0
[ -d "$SANDBOX/limbic" ]          && check "limbic/ preserved"            1 || check "limbic/ preserved"            0
[ -d "$SANDBOX/cerebellum" ]      && check "cerebellum/ preserved"        1 || check "cerebellum/ preserved"        0
[ -d "$SANDBOX/sources" ]         && check "sources/ preserved"           1 || check "sources/ preserved"           0
[ -d "$SANDBOX/dreams" ]          && check "dreams/ preserved"            1 || check "dreams/ preserved"            0
[ -d "$SANDBOX/stubs" ]           && check "stubs/ preserved"             1 || check "stubs/ preserved"             0

# Git history reset to a single commit
if [ -d "$SANDBOX/.git" ]; then
  COMMIT_COUNT=$(cd "$SANDBOX" && git rev-list --count HEAD 2>/dev/null || echo 0)
  if [ "$COMMIT_COUNT" = "1" ]; then
    check "Git: exactly one commit" 1
  else
    check "Git: exactly one commit (got $COMMIT_COUNT)" 0
  fi
  MSG=$(cd "$SANDBOX" && git log -1 --pretty=%s 2>/dev/null || echo "")
  if [ "$MSG" = "Initial brain commit" ]; then
    check "Git: commit message is 'Initial brain commit'" 1
  else
    check "Git: commit message is 'Initial brain commit' (got '$MSG')" 0
  fi
else
  check "Git: .git directory exists after init" 0
fi

# --- Cleanup ---
echo
if [ "$fail" = "0" ]; then
  rm -rf "$SANDBOX"
  echo "PASS — init-brain.sh works correctly"
else
  echo "FAIL — $fail assertion(s) failed."
  echo "Sandbox preserved for inspection: $SANDBOX"
fi
exit $fail
