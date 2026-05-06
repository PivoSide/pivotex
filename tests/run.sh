#!/usr/bin/env bash
# PIVOTEX test runner (Linux/macOS)
# Usage: bash tests/run.sh 02-consolidation

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <test-id>" >&2
  exit 1
fi

TEST_ID="$1"
HERE="$(cd "$(dirname "$0")" && pwd)"
FIXTURE_DIR="$HERE/fixtures/$TEST_ID"

if [ ! -d "$FIXTURE_DIR" ]; then
  echo "No fixture for test '$TEST_ID' at $FIXTURE_DIR" >&2
  echo
  echo "Available tests with fixtures:"
  ls -1 "$HERE/fixtures" 2>/dev/null
  echo
  echo "See tests/cognitive-memory-tests.md for the full catalog (some are spec-only)."
  exit 1
fi

SANDBOX="${TMPDIR:-/tmp}/pivotex-test-$TEST_ID"
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"

if [ -d "$FIXTURE_DIR/seed" ]; then
  cp -R "$FIXTURE_DIR/seed/." "$SANDBOX/"
fi

echo
echo "================================================================"
echo " Sandbox brain ready: $SANDBOX"
echo "================================================================"
echo
echo "Open tests/cognitive-memory-tests.md and find test '$TEST_ID'."
echo "Point your agent at:"
echo "  $SANDBOX"
echo
echo "Perform the Action specified in the test."
echo
read -p "Press Enter when the agent has finished..." _

CHECKS="$FIXTURE_DIR/checks.sh"
if [ ! -f "$CHECKS" ]; then
  echo "No checks.sh in fixture; cannot verify deterministically." >&2
  exit 2
fi

echo
echo "Running assertions..."
bash "$CHECKS" "$SANDBOX"
EXIT=$?
echo
if [ $EXIT -eq 0 ]; then
  echo "PASS — $TEST_ID"
else
  echo "FAIL — $TEST_ID (exit $EXIT)"
fi
exit $EXIT
