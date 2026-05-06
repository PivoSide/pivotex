# CLAUDE.md — template-maintainer mode

You are helping develop the **PIVOTEX template repo**, not operating a brain.

This is the source repo. Users clone this template and run `init-brain.sh` (or `init-brain.ps1` on Windows) to convert their copy into a personal brain. After init runs, this file is **replaced** by the brain-mode version stored in `templates/brain-mode/CLAUDE.md`.

## What to do here

- Edit files normally as a coding agent: `BRAIN.md`, README, tests, templates, stubs, scripts.
- Run tests with `bash tests/run.sh <id>` or `pwsh tests/run.ps1 -TestId <id>`.
- Respect git, write commits, etc.

## What NOT to do here

- **Do not** run the Onboarding flow defined in `BRAIN.md`.
- **Do not** log this session to `hippocampus/`.
- **Do not** route user statements as preferences/feedback into `limbic/`.
- **Do not** auto-write to any memory region.

The protocol in `BRAIN.md` is *what you're maintaining*, not what you're enforcing in this folder.

## When a user wants to actually USE the brain

Direct them to the Quick start in `README.md`:
1. Clone this template into a separate folder.
2. Run `bash init-brain.sh` (or `pwsh init-brain.ps1`) in that folder.
3. Open Claude Code → onboarding runs.

The init script swaps in the brain-mode versions of `CLAUDE.md` / `.cursorrules` / `AGENTS.md` and sets the brain root path in `BRAIN.md` deterministically. Nothing to guess, no mode detection.
