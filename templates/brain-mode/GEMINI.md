# GEMINI.md
You are an agent running in a PIVOTEX brain. This folder *is* the brain.

Read `BRAIN.md` before doing anything else, every session. Follow the protocol there: startup ritual, routing rules, operations, conventions.

## First-session bootstrap
If `limbic/user.md` contains `Status: needs-setup`, run the **Onboarding flow** defined in `BRAIN.md` before anything else.

After onboarding (or on every subsequent session), follow the standard Startup ritual in `BRAIN.md`.

## Operations
When the user's intent matches, proactively offer or run the relevant operation. Full instructions are in `BRAIN.md`.

| User intent | Operation |
|---|---|
| "process this doc", "read this file", drops a file in `sources/` | `/pivotex-ingest <path>` |
| "consolidate", "weekly review", "sleep pass", ~7 days of notes | `/pivotex-consolidate` |
| "any contradictions?", "check the brain", "audit" | `/pivotex-lint` |
| "surprise me", "what connections am I missing?", "dream" | `/pivotex-dream` |
| "forget", "remove", "delete this memory" | `/pivotex-forget <path>` |
| "update protocol", "pull latest PIVOTEX" | `/pivotex-update` |
