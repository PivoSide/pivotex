#!/usr/bin/env bash
# update-brain.sh — deterministic phase of /pivotex-update.
# Handles all git operations. Run this first, then let the agent do the BRAIN.md merge.

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "========================================================="
echo " PIVOTEX protocol update — deterministic phase"
echo "========================================================="
echo ""

# 1. Working-tree check
if ! git -C "$HERE" diff --quiet || ! git -C "$HERE" diff --cached --quiet; then
  echo "ERROR: Uncommitted changes detected. Stash or commit them first."
  exit 1
fi

# 2. Ensure upstream remote
if ! git -C "$HERE" remote get-url upstream >/dev/null 2>&1; then
  git -C "$HERE" remote add upstream https://github.com/PivoSide/pivotex.git
  echo "-> Added upstream remote."
fi

# 3. Fetch
echo "-> Fetching upstream/main..."
git -C "$HERE" fetch upstream main -q

# 4. Version comparison
LOCAL_VER=$(cat "$HERE/VERSION" 2>/dev/null || echo "unknown")
UPSTREAM_VER=$(git -C "$HERE" show upstream/main:VERSION 2>/dev/null | tr -d '[:space:]' || echo "unknown")
echo "-> Local:    $LOCAL_VER"
echo "-> Upstream: $UPSTREAM_VER"

if [ "$LOCAL_VER" = "$UPSTREAM_VER" ]; then
  echo "-> Already on latest version."
  read -r -p "Continue anyway (re-apply protocol files)? [y/N]: " force
  case "$force" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Nothing to do."; exit 0 ;;
  esac
fi

# 5. Show changed protocol files (not full diff — just names)
echo ""
echo "-> Protocol files that will change:"
git -C "$HERE" diff --name-only upstream/main -- CLAUDE.md GEMINI.md .cursorrules AGENTS.md stubs/ VERSION || true
echo ""

read -r -p "Apply update? [y/N]: " ans
case "$ans" in
  [yY]|[yY][eE][sS]) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

# 6. Checkout protocol files (user data never touched)
echo "-> Updating protocol files..."
git -C "$HERE" checkout upstream/main -- CLAUDE.md GEMINI.md .cursorrules AGENTS.md stubs/ VERSION

# 7. Install Claude Code slash commands
if [ -d "$HERE/stubs/claude-commands" ]; then
  echo "-> Installing Claude Code slash commands..."
  mkdir -p "$HERE/.claude/commands"
  cp -f "$HERE"/stubs/claude-commands/*.md "$HERE/.claude/commands/"
fi

# 8. Stage everything except BRAIN.md (agent handles that)
git -C "$HERE" add --all -- ':!BRAIN.md'

echo ""
echo "========================================================="
echo " Deterministic phase complete."
echo "========================================================="
echo ""
echo "Now ask your agent to complete the update:"
echo "  'Complete the BRAIN.md merge for /pivotex-update'"
echo ""
echo "The agent will merge upstream protocol into BRAIN.md while"
echo "preserving your Identity block, then commit."
