# Sources
Raw inputs. **Immutable.** Never edited, never overwritten.

## Naming
`<YYYY-MM-DD>_<short-slug>.<ext>`
Examples: `2026-05-06_karpathy-llm-wiki.md`, `2026-05-06_meeting-notes-launch.md`.

## Workflow
1. Drop a file here.
2. Run `/pivotex-ingest <path>` (see `BRAIN.md`).
3. Cortex pages get updated/created with citations back to this file.
4. The file stays here, untouched, forever.

## Why immutable
Every cortex claim cites its source. If the source can change, citations rot.
Keep originals; derive interpretations elsewhere.
