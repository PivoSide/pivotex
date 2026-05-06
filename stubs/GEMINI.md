# GEMINI.md
Read `<BRAIN_ROOT>/BRAIN.md` before doing anything else, every session. Follow the protocol there: startup ritual, routing rules, operations, conventions.

## First-session bootstrap
If `<BRAIN_ROOT>/limbic/user.md` contains `Status: needs-setup`, run the **Onboarding flow** defined in `<BRAIN_ROOT>/BRAIN.md` before anything else.

After onboarding (or on every subsequent session), follow the standard Startup ritual in `<BRAIN_ROOT>/BRAIN.md`.

## Shell commands
Detect the platform before running any shell command and adapt accordingly:
- **Windows (PowerShell 5.1):** use `;` instead of `&&`; use `if (-not $?) { ... }` instead of `||`; omit `2>/dev/null` or replace with `-ErrorAction SilentlyContinue`; use `$env:TEMP` instead of `/tmp`.
- **macOS / Linux (bash/zsh):** standard POSIX syntax works as written.
- Pure git commands work unchanged on all platforms.
Run each command as a separate step when in doubt — never assume `&&` works.

## Operations
When the user's intent matches, proactively offer or run the relevant operation. Full instructions are in `<BRAIN_ROOT>/BRAIN.md`.

| User intent | Operation |
|---|---|
| "process this doc", "read this file", drops a file in `sources/` | `/pivotex-ingest <path>` |
| "consolidate", "weekly review", "sleep pass", ~7 days of notes | `/pivotex-consolidate` |
| "any contradictions?", "check the brain", "audit" | `/pivotex-lint` |
| "surprise me", "what connections am I missing?", "dream" | `/pivotex-dream` |
| "forget", "remove", "delete this memory" | `/pivotex-forget <path>` |
| "update protocol", "pull latest PIVOTEX" | `/pivotex-update` |

<!-- Replace <BRAIN_ROOT> with the absolute path to your PIVOTEX brain folder. -->
