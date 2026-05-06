# Extending PIVOTEX

Concrete recipes for the most common kinds of contributions and customizations. Each recipe lists files to touch, what to change, and how to test.

Read [`ARCHITECTURE.md`](ARCHITECTURE.md) before extending. Read [`../BRAIN.md`](../BRAIN.md) for the canonical protocol.

## Table of contents
- [Adding a new mode](#adding-a-new-mode)
- [Adding a new operation](#adding-a-new-operation)
- [Adding a new salience cue](#adding-a-new-salience-cue)
- [Adding a new test](#adding-a-new-test)
- [Adding a new region](#adding-a-new-region)
- [Customizing the consolidation cycle](#customizing-the-consolidation-cycle)
- [Adding tool-specific automation](#adding-tool-specific-automation)
- [Translating PIVOTEX](#translating-pivotex)

---

## Adding a new mode

Modes are loaded based on the user's intent and shape what context the agent pulls in.

**Files to touch:**
- `cerebellum/modes/<mode>.md` (new)
- `BRAIN.md` (Modes section — add a row)

**Recipe — adding `debug` mode:**

1. Create `cerebellum/modes/debug.md`:

   ```markdown
   # Mode: debug
   Loaded when the user signals debugging intent ("broken", "doesn't work", "error", "why is X").

   ## Behavior
   - Don't speculate. Reproduce first.
   - Surface relevant cortex pages (the system being debugged).
   - Ask for the exact error, exact reproduction, exact environment.
   - End with: a hypothesis + the next experiment to confirm/refute.

   ## What to load
   - `cortex/concepts/<system-name>.md` if cued.
   - Recent `hippocampus/` entries on the same topic.
   - `limbic/feedback/` for "we tried X, it didn't work."
   ```

2. Update `BRAIN.md` Modes table to point at the new file.

3. Add a salience cue in `salience.md`:

   ```markdown
   ## Cue: "broken" | "error" | "doesn't work" | "why is"
   → cerebellum/modes/debug.md (weight: 0.9)
   ```

4. Test by writing a hippocampus entry triggering the cue and confirming the agent loads `debug.md`. (No automated test for mode loading yet — write one if you want.)

---

## Adding a new operation

Operations (slash-commands) are user-invoked workflows the agent runs. Existing: `/pivotex-ingest`, `/pivotex-consolidate`, `/pivotex-lint`, `/pivotex-dream`, `/pivotex-forget`.

**Files to touch:**
- `BRAIN.md` (Operations section — add the new op)
- Optionally `cerebellum/<op-name>.md` if the op needs detailed step-by-step procedures
- Add a test fixture in `tests/fixtures/`

**Recipe — adding `/inspect <topic>`:**

`/inspect` should return all cortex pages relevant to a topic without LLM synthesis — useful for auditing what the agent actually knows.

1. Add to `BRAIN.md` under Operations:

   ```markdown
   ### `/inspect <topic>`
   Return all cortex pages and limbic entries that match `<topic>` by salience cue.
   1. Match `<topic>` against cues in `salience.md`.
   2. List every file the cues map to, with weight.
   3. Print each file's `Status:` and `Last updated:` headers.
   4. Do NOT synthesize. Output the raw file list with one-line summaries from each page's `## Summary` if present.
   5. Append a one-line entry to `hippocampus/<today>.md`: "Inspected: <topic> → N pages."
   ```

2. Optionally add `cerebellum/inspect.md` with implementation notes if behavior is complex.

3. Add a test fixture: `tests/fixtures/10-inspect/` with seed cortex pages and `checks.{ps1,sh}` asserting the agent's response includes expected file paths.

4. Document in `tests/cognitive-memory-tests.md` (analog: directed retrieval, à la Tulving's free-recall vs. cued-recall distinction).

---

## Adding a new salience cue

The salience map drives selective context loading. New cues come from:
- `/pivotex-consolidate` tuning weights based on what fired and was useful.
- Hand-edits when a recurring pattern is obvious.

**Files to touch:**
- `salience.md` only.

**Recipe:**

```markdown
## Cue: "<term1>" | "<term2>" | regex pattern
→ <path/to/file.md> (weight: 0.5, last: YYYY-MM-DD)
```

Weights: 0.1–1.0. New cues start at 0.5. `/pivotex-consolidate` adjusts ±0.1 based on use.

---

## Adding a new test

PIVOTEX tests are deterministic: agent reasoning isn't, but file-state verification is. See [`../tests/README.md`](../tests/README.md) for the philosophy and runner mechanics.

**Files to touch:**
- `tests/fixtures/<NN>-<slug>/seed/` — files placed in the sandbox before the action
- `tests/fixtures/<NN>-<slug>/checks.ps1` — Windows assertions (exit 0 = pass)
- `tests/fixtures/<NN>-<slug>/checks.sh` — POSIX assertions (exit 0 = pass)
- `tests/cognitive-memory-tests.md` — describe the test and its cognitive analog

**Recipe — adding test 06 (salience decay):**

1. Pick the cognitive analog: synaptic weakening / use-it-or-lose-it.

2. Design the seed:
   - `salience.md` with a cue that fired N times, all unused (recorded in hippocampus).

3. Design the assertion: after `/pivotex-consolidate`, the cue's weight should be ≤ 0.2.

4. Build:

   ```
   tests/fixtures/06-salience-decay/
   ├── seed/
   │   ├── salience.md                   # cue with weight 0.5 + usage log
   │   └── hippocampus/
   │       └── 2026-04-29.md ... 2026-05-03.md   # 5 days, cue fired, never referenced
   ├── checks.ps1
   └── checks.sh
   ```

5. `checks.sh`:

   ```bash
   #!/usr/bin/env bash
   SANDBOX="$1"
   fail=0
   check() {
     [ "$2" = "1" ] && echo "  PASS — $1" || { echo "  FAIL — $1"; fail=$((fail+1)); }
   }
   weight=$(grep -E "weight: [0-9.]+" "$SANDBOX/salience.md" | head -1 | sed -E 's/.*weight: ([0-9.]+).*/\1/')
   awk -v w="$weight" 'BEGIN { exit !(w <= 0.2) }' && check "Cue weight decayed to ≤ 0.2" 1 || check "Cue weight decayed to ≤ 0.2" 0
   exit $fail
   ```

6. Mirror the same logic in `checks.ps1`.

7. Update `tests/cognitive-memory-tests.md`:
   - Mark test `06` as `Status: shipped`.
   - Document the seed, action, expected, verification.

8. Run it locally: `bash tests/run.sh 06-salience-decay`.

**Cross-platform parity:** every check must produce the same PASS/FAIL on Windows and POSIX. If you can only test one, mark the PR `needs-cross-platform-check`.

---

## Adding a new region

Heavy. Don't do this lightly. Adding a region implies you've found a memory type the existing six can't handle.

**Files to touch:**
- New folder at root (e.g., `amygdala/` for emotional weighting)
- `BRAIN.md` Regions table (add a row + behavior contract)
- `BRAIN.md` Routing rules (specify what goes there)
- `salience.md` (cues that surface from the new region)
- Possibly `salience.md`, `cerebellum/`, etc. if cross-cutting

**Recipe — adding `amygdala/` (emotional/salience weighting):**

1. Define the contract: what's the lifecycle? Append-only? Built by consolidation? Edited by user only?

2. Add to `BRAIN.md`:
   - Regions table: name, function, behavior.
   - Routing: what input goes there.
   - Conventions if it has unique fields.

3. Update `docs/ARCHITECTURE.md` cognitive-memory-map table with the new region.

4. Add tests for any new routing rules.

5. Open an issue *before* writing code. The bar for new regions is high: each one expands the surface area contributors must reason about.

---

## Customizing the consolidation cycle

`/pivotex-consolidate` is the brain's sleep pass. Defined in `BRAIN.md` Operations.

**Files to touch:**
- `BRAIN.md` Operations section.
- Optionally `cerebellum/pivotex-consolidate.md` for detailed steps.

**Common customizations:**
- Different archive thresholds (default: 30 days for hippocampus).
- Different salience weight deltas (default: ±0.1).
- Adding cross-region operations (e.g., promote feedback to procedure if seen 3+ times).

Test changes with a fixture: seed N hippocampus entries, run `/pivotex-consolidate`, assert expected promotions/archivals.

---

## Adding tool-specific automation

Optional. PIVOTEX is intentionally tool-agnostic — automation lives as **examples in docs**, not core machinery.

If you want to add Claude Code hooks, cron jobs, or per-tool integrations:
- Place them under `docs/recipes/<tool>/`.
- Document clearly that they're optional.
- Don't add config files at the repo root that a different tool might choke on.

---

## Translating PIVOTEX

The protocol is English-language by default. To translate:

1. The user's *content* (hippocampus, cortex, limbic) can be in any language — that's the user's choice; the protocol doesn't constrain it.

2. The *protocol files* (`BRAIN.md`, README, docs/) can be translated. Translation PRs should:
   - Translate one document at a time.
   - Keep file names English (`BRAIN.md`, not `CERVEAU.md`).
   - Translate routing-rule keywords carefully — modes detect English keywords by default ("plan", "build", "debug"). To support other languages, extend the salience map rather than rename modes.

3. The *test fixtures* stay English — assertions match English strings. Add localized fixtures alongside if you want to test localized behavior.

---

## When in doubt

Open an issue. PIVOTEX prefers conversation over speculative PRs.
