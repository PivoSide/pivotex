# BRAIN.md
> PIVOTEX — a brain-shaped memory for AI agents. Read this file first, every session, every tool.

## Identity
- **Owner:** _filled during Onboarding (see below)_
- **Brain root:** _absolute path of the folder containing this file; filled during Onboarding_
- **Created:** _date of first session; filled during Onboarding_
- **Voice & rules:** `limbic/self.md`
- **User profile:** `limbic/user.md`

## Regions
| Path | Function | Behavior |
|---|---|---|
| `BRAIN.md` | Bootstrap | Always read first |
| `hippocampus/` | Episodic | Append-only daily notes; fades after 30d via consolidation |
| `cortex/` | Semantic | Topic pages, cross-linked. Built by consolidation, not direct writes |
| `cerebellum/` | Procedural | Workflows the agent runs |
| `limbic/` | Affective | User profile, agent self, feedback, salience-weighted preferences |
| `salience.md` | Attention | Cue → memory map. Drives selective context loading |
| `sources/` | Raw evidence | Immutable. Never edited |
| `dreams/` | Speculative | Unconfirmed connections; user reviews and promotes/rejects |

## Startup ritual (every session, in this order)
1. Read `BRAIN.md` (this file).
2. Read `limbic/self.md` and `limbic/user.md`.
3. Read `hippocampus/<today>.md` — create from `hippocampus/_template.md` if missing.
4. Read `hippocampus/_last7days.md`.
5. Read `salience.md`.
6. Scan the user's first message → match cues from `salience.md` → load matched files.
7. Detect mode (see Modes) → load `cerebellum/modes/<mode>.md` if it exists.

## Routing rules (where new facts land)
| Input signal | Destination | Notes |
|---|---|---|
| Correction ("no, do X") | `limbic/feedback/<topic>.md` | Lead with rule. Include **Why:** and **How to apply:** |
| Confirmation of an unusual choice | `limbic/feedback/<topic>.md` | Save successes too, not just corrections |
| Preference / identity | `limbic/user.md` | Edit in place, don't append |
| Project / world fact | `cortex/entities/<x>.md` or `cortex/concepts/<x>.md` | New page if none exists |
| Procedure / workflow | `cerebellum/<workflow>.md` | One file per workflow |
| Daily activity, decisions | `hippocampus/<today>.md` | Append, timestamped |
| External document | `sources/<YYYY-MM-DD>_<slug>.<ext>` | Then run `/pivotex-ingest` |
| Speculative connection | `dreams/<YYYY-MM-DD>_<slug>.md` | `Status: unconfirmed` |

When uncertain about routing, ask the user before writing.

## Onboarding (first session)
If `limbic/user.md` contains `Status: needs-setup`, run this flow **before anything else** — skip the standard Startup ritual until onboarding is done.

1. Greet warmly. Briefly explain: "This is your first session in this PIVOTEX brain. Let me ask a few questions so I can remember who you are across sessions."
2. Ask, one question at a time, waiting for the answer:
   - "What should I call you?"
   - "What languages do you prefer? (e.g., French casual + English technical)"
   - "What kind of work will we mostly do together? (development, writing, research, planning, mixed, …)"
   - "Any communication preferences? (terse vs detailed, formal vs casual, anything to avoid)"
   - "What are 1–3 current goals you're working on?"
3. Detect the brain root: it's the absolute path of the folder containing `BRAIN.md` (the parent of `limbic/`).
4. Write the answers to `limbic/user.md`. Set `Status: active`. Set `Last updated:` to today's date.
5. Update `BRAIN.md`'s Identity section: replace the `_filled during Onboarding_` placeholders with the user's name (and optional email), the detected brain root, and today's date.
6. Create today's hippocampus entry from `hippocampus/_template.md` and log a one-liner: "Onboarded — set up profile, ready to work."
7. Confirm: "Setup done. I'll remember all of this across sessions and tools. What would you like to do first?"

After onboarding, every subsequent session follows the standard Startup ritual.

## Modes
Detect from user's intent. Light vs heavy load.
- **plan** — "let's plan", "design", "approach", "how should we" → `cerebellum/modes/plan.md` + relevant cortex
- **build** — "implement", "code", "fix", "ship" → `cerebellum/modes/build.md` (create when needed)
- **debug** — "broken", "error", "doesn't work", "why is" → `cerebellum/modes/debug.md` (create when needed)
- **research** — "what is", "explain", "compare" → load relevant cortex pages by cue match
- **casual** — default, no specific signal → static priming only

## Operations

### `/pivotex-ingest <source-path>`
1. Read the source. Don't summarize back to the user — just confirm "ingesting".
2. Extract: entities, concepts, claims, dates, decisions.
3. For each finding:
   - Cortex page exists → update + add citation `(see sources/<file>)`.
   - New → create cortex page with citation.
   - Contradicts existing → add a `## Conflicts` section, list both with sources. Never silently overwrite.
4. Add new cues to `salience.md` mapping to the new/updated pages.
5. Append a one-line entry to `hippocampus/<today>.md`: what was ingested + which pages changed.
6. **Sources are never edited. Ever.**

### `/pivotex-consolidate`
The "sleep" pass. Run weekly or on demand.
1. Read last 7–30 days of `hippocampus/`.
2. Patterns mentioned 3+ times across days → promote to a `cortex/concepts/` page (or strengthen existing).
3. For each cue in `salience.md`: fired + the loaded file was actually used → **+0.1** weight; fired + unused → **−0.1**. Clamp to [0.1, 1.0].
4. Hippocampus entries older than 30 days → compress into `hippocampus/archive/<YYYY-MM>.md`. Keep raw originals in `hippocampus/archive/raw/`.
5. Run `/pivotex-lint`. Append findings to today's hippocampus entry.
6. **Length enforcement** (see Length & decomposition):
   - Splittable files >400 lines → run the **Split protocol**. Update every cross-reference. Log the split to today's hippocampus entry.
   - Splittable files 250–400 lines without `## Summary` and `## Outline` → add them now (auto-derive `## Outline` from existing `## H2` headers).
   - Always-single files >400 lines → flag in lint output (no auto-action).

### `/pivotex-lint`
Read-only audit. Report:
- Contradictions between cortex pages.
- Dangling `[[wiki-links]]`.
- `Status: active` items not touched in >90 days.
- Cortex pages without source citations.
- `dreams/` entries older than 30 days awaiting review.
- **Length violations**:
  - Splittable files >400 lines (will be auto-split next `/pivotex-consolidate`).
  - Splittable files 250–400 lines missing `## Summary` or `## Outline`.
  - Always-single files >400 lines (need manual editing — see Length & decomposition).

Output goes to today's hippocampus entry.

### `/pivotex-dream`
1. Sample 5–10 hippocampus entries (last 30d) + 5 random cortex pages.
2. Look for non-obvious patterns, hypotheses, connections.
3. Write to `dreams/<YYYY-MM-DD>_<slug>.md` with `Status: unconfirmed`.
4. Frame as: "I noticed X and Y; could be related because Z." Never assert as fact.
5. User confirms → promote to `cortex/`. User rejects → delete.

### `/pivotex-forget <path-or-topic>`
Intentional removal. Move the file to `archive/forgotten/`. Leave a one-line tombstone in the original location: `Forgotten YYYY-MM-DD — see archive/forgotten/<file>`.

### `/pivotex-update`
Pull protocol updates from upstream into this brain without touching user data.

**Preconditions:** brain was created from the PIVOTEX template; git is initialized; current working tree is clean (or user accepts a stash).

1. Confirm with user: *"I'll fetch the latest PIVOTEX protocol and update protocol files here. Your data (`hippocampus/`, `cortex/`, `limbic/`, `sources/`, `dreams/`, `salience.md`) will not be touched. Continue? [y/N]"*
2. **Working-tree check:** if `git status` shows uncommitted changes, ask user to stash or commit first; do not proceed.
3. **Ensure upstream remote:** run `git remote get-url upstream` — if it fails or is missing, run `git remote add upstream https://github.com/pivoside/pivotex.git`.
4. **Fetch:** `git fetch upstream main`.
5. **Read versions:** local `VERSION` (treat missing as `unknown`) and `git show upstream/main:VERSION`.
6. **Show what would change:**
   ```
   git diff upstream/main -- BRAIN.md CLAUDE.md .cursorrules AGENTS.md stubs/ VERSION
   ```
7. **BRAIN.md surgical merge:**
   a. Extract user's Identity block from local `BRAIN.md` — lines from `## Identity` up to (but not including) the next `## ` header.
   b. Read upstream `BRAIN.md` content via `git show upstream/main:BRAIN.md`.
   c. In the fetched content, replace the `## Identity` block (same delimiter rule) with the user's preserved one.
   d. Write the merged result over local `BRAIN.md`.
8. **Wholly-replaceable protocol files** (no user customization expected by design):
   ```
   git checkout upstream/main -- CLAUDE.md .cursorrules AGENTS.md stubs/ VERSION
   ```
   Exception: if local diff against the *previous* upstream snapshot of any of these shows user edits, do NOT silently overwrite. Show the user their changes and ask `[k]eep yours / [u]pstream / [a]bort`.
9. **Never touched, ever:**
   `hippocampus/`, `cortex/`, `limbic/`, `sources/`, `dreams/`, `salience.md`, `archive/`, and any `cerebellum/modes/<custom>.md` not present in upstream.
10. **Stage and review:** `git add -A` then show `git diff --staged` to the user.
11. **Log to hippocampus:** append a one-line entry to `hippocampus/<today>.md`: *"Updated PIVOTEX protocol `<old-version>` → `<new-version>`. Files: `<list>`."*
12. **On user confirmation:** `git commit -m "Update PIVOTEX protocol to <new-version>"`.
    **On rejection:** run `git restore --staged .` then `git checkout -- .` (unstage and discard).

## Conventions
- **Cross-references:** `[[cortex/concepts/x.md]]` — works as link and prose.
- **Citations:** every cortex claim from a document cites it: `(see sources/<file>)`.
- **Status field:** every memory file declares one of: `active | superseded-by [link] | uncertain | archived | forgotten`.
- **Salience weight:** scale 0.1–1.0. New cues start at 0.5.
- **Dates:** absolute YYYY-MM-DD. Never "yesterday".
- **Density:** cortex pages prefer dense bullets over essays. Hippocampus entries are timestamped one-liners.
- **Language:** match the user's language. Confirm at session start if ambiguous.

## Length & decomposition

LLM context degrades on files over ~300 lines. PIVOTEX enforces deterministic length budgets so no file the agent reads is too long to reason about reliably.

### Limits

| Threshold | Lines | Rule |
|---|---|---|
| **Soft limit** | 250 | File MUST have `## Summary` (≤20 lines) and `## Outline` near the top |
| **Hard limit** | 400 | File MUST be split during the next `/pivotex-consolidate` (see Split protocol) |

### Always-single (exempt from splitting)

These files must stay as one file by content discipline, not splitting:
- `BRAIN.md` (this file), `README.md`, `CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `LICENSE`, `salience.md`.

If they cross the hard limit, `/pivotex-lint` flags them for manual editing — split is not allowed.

### Read protocol (selective loading)

When an operation loads a file >250 lines:
1. Read **only** `## Summary` and `## Outline` first.
2. Drill into specific subsections (or child files) only if the user's cue or the current task explicitly demands it.
3. For files in folder form (post-split), `_index.md` is what gets loaded for priming; child files load on demand.

### Split protocol

Triggered by `/pivotex-consolidate` step 6 when a *splittable* file exceeds 400 lines.

**Case A — Multiple H2 sections, each ≥ 50 lines:**
1. Create folder `<original-stem>/` next to the original.
2. Move each `## H2` section into its own file: `<original-stem>/<h2-slug>.md`. Carry the parent's `Status:`, `Sources:`, etc. Add a frontmatter pointer `parent: <original-stem>/_index.md`.
3. Replace the original with `<original-stem>/_index.md` containing only:
   - The original frontmatter (Status, Last updated, Sources).
   - `## Summary`.
   - `## Outline` — list of child files with one-line descriptions (acts as the table of contents).
4. Update every `[[<original-path>]]` cross-reference in the brain to `[[<original-stem>/_index.md]]`.
5. Append to today's `hippocampus/<today>.md`: "Split <path> into <N> child files: [<list>]."

**Case B — Single H2 with bulk content (>400 lines but only one major section):**
1. Auto-split fails for monolithic prose. Do NOT split.
2. Prepend `## TL;DR` (≤20 lines) and `## Sections` (table of `## H3`s with one-liners).
3. Flag in `/pivotex-lint` output for human review.

**Case C — Many short H2s (>20 sections, total >400 lines):**
Same as Case A but threshold each H2 at ≥30 lines instead of 50; group H2s smaller than that into a single child file (`misc.md`).

### Header slugs (for filenames)

Deterministic transformation: lowercase, replace whitespace and `-` runs with single `-`, strip non-`[a-z0-9-]` characters. E.g., `## How it feels to use` → `how-it-feels-to-use.md`. Truncate to 60 chars.

### Authoring guidance

Pages expected to grow past 250 lines (e.g., a cortex concept that accumulates many sub-claims): start with `## Summary` + `## Outline` from day one, even when short. The cost is a few lines; the benefit is no scramble at the soft limit.

## Cross-platform usage
This brain is tool-agnostic. Each tool gets a 3-line stub pointing here. See `stubs/`.
- Claude Code: copy `stubs/CLAUDE.md` into any project.
- Gemini CLI: copy `stubs/GEMINI.md` into any project.
- Cursor: copy `stubs/.cursorrules`.
- Codex / Copilot: copy `stubs/AGENTS.md`.
- API or custom agent: paste `stubs/system-prompt.txt` into the system prompt.

**The brain is portable. The shells are disposable.**
