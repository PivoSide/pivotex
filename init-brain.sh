#!/usr/bin/env bash
# init-brain.sh — convert this template into a personal PIVOTEX brain.
# One-time use. Self-deletes on success.
#
# What this does (no prompts — fully deterministic):
#   - Replaces root CLAUDE.md, .cursorrules, AGENTS.md with brain-mode versions
#   - Replaces README.md with the brain-mode user-facing version
#   - Sets the brain root path in BRAIN.md
#   - Removes ALL maintainer-only artifacts: tests/, docs/, CONTRIBUTING.md, templates/
#   - Resets git history to a single "Initial brain commit"
#   - Removes init-brain.sh and init-brain.ps1

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

cat <<EOF

=========================================================
 PIVOTEX brain activation
=========================================================

This will convert this folder into your personal PIVOTEX brain.

This action will:
  - Replace CLAUDE.md, .cursorrules, AGENTS.md, README.md with brain-mode versions
  - Set the brain root path in BRAIN.md
  - REMOVE: tests/, docs/, CONTRIBUTING.md, templates/, init-brain.{sh,ps1}
  - RESET git history (single "Initial brain commit")

This is one-time and irreversible (unless you re-clone).

EOF

read -r -p "Continue? [y/N]: " ans
case "$ans" in
  [yY]|[yY][eE][sS]) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

if [ ! -d "$HERE/templates/brain-mode" ]; then
  echo "ERROR: templates/brain-mode/ not found." >&2
  echo "Either this script has already run, or the template was modified." >&2
  exit 1
fi

echo
echo "-> Replacing root agent-config files with brain-mode versions..."
cp -f "$HERE/templates/brain-mode/CLAUDE.md"     "$HERE/CLAUDE.md"
cp -f "$HERE/templates/brain-mode/.cursorrules"  "$HERE/.cursorrules"
cp -f "$HERE/templates/brain-mode/AGENTS.md"     "$HERE/AGENTS.md"
cp -f "$HERE/templates/brain-mode/README.md"     "$HERE/README.md"

echo "-> Setting brain root path in BRAIN.md..."
PLACEHOLDER='_absolute path of the folder containing this file; filled during Onboarding_'
ESCAPED_HERE=$(printf '%s' "$HERE" | sed -e 's|[\\/&]|\\&|g')
sed -i.bak "s|${PLACEHOLDER}|\`${ESCAPED_HERE}\`|" "$HERE/BRAIN.md"
rm -f "$HERE/BRAIN.md.bak"

echo "-> Removing maintainer-only artifacts..."
rm -rf "$HERE/templates"
rm -rf "$HERE/tests"
rm -rf "$HERE/docs"
rm -f  "$HERE/CONTRIBUTING.md"
rm -f  "$HERE/CHANGELOG.md" 2>/dev/null || true

echo "-> Resetting git history..."
rm -rf "$HERE/.git"
(
  cd "$HERE"
  git init -q
  git add -A
  git -c user.email=brain@local -c user.name="PIVOTEX brain" commit -q -m "Initial brain commit" || true
)

echo "-> Removing init scripts..."
rm -f "$HERE/init-brain.sh" "$HERE/init-brain.ps1"

cat <<EOF

=========================================================
 Activation complete.
=========================================================

Next steps:
  1. Open Claude Code (or Cursor / Codex) in this folder.
  2. Say hi. The agent will run the Onboarding flow defined in BRAIN.md.

EOF
