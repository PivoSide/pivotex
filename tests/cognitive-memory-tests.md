# Cognitive memory tests for PIVOTEX

Each test mirrors a phenomenon from human memory research, applied to PIVOTEX's protocol. Verification is deterministic: file existence, content match, immutability checks.

Format:
- **Cognitive analog** — the human-memory phenomenon being measured
- **Setup** — what the seed brain contains
- **Action** — the exact instruction to give your agent
- **Expected** — what should be true after
- **Verification** — how `checks.{ps1,sh}` confirms it
- **Status** — `shipped` (seed + checks present) or `spec` (description only)

---

## 01 — Cued recall
**Cognitive analog:** Tulving's encoding-specificity / cue-driven retrieval.
**Setup:** `cortex/concepts/paris.md` exists with content "The Eiffel Tower is in Paris."
**Action:** Send the agent: *"What's notable in Paris?"*
**Expected:** Agent's response (logged to `hippocampus/<today>.md`) mentions the Eiffel Tower.
**Verification:** `CONTAINS hippocampus/<today>.md "Eiffel Tower"`.
**Status:** spec (verification depends on agent logging its response — see Limitations in tests/README.md).

---

## 02 — Consolidation pattern detection
**Cognitive analog:** Hebbian consolidation — repeated co-occurrence promotes a trace from episodic to semantic.
**Setup:** Three hippocampus entries on consecutive days, each mentioning "deploy via PivoCloud."
**Action:** Run `/pivotex-consolidate`.
**Expected:** A new cortex page exists (e.g., `cortex/concepts/pivocloud-deploy.md`) summarizing the pattern, citing the hippocampus entries.
**Verification:** file exists; contains "PivoCloud"; references the three hippocampus dates.
**Status:** shipped.

---

## 03 — Source attribution (ingest with citation)
**Cognitive analog:** Source monitoring — knowing where you learned something.
**Setup:** `sources/2026-05-01_llm-wiki.md` containing claims about LLM wiki pattern.
**Action:** Run `/pivotex-ingest sources/2026-05-01_llm-wiki.md`.
**Expected:** New cortex page(s) created summarizing the source, each claim citing `(see sources/2026-05-01_llm-wiki.md)`. Source file unchanged.
**Verification:** cortex page exists; contains the citation string; source MD5 unchanged.
**Status:** shipped.

---

## 04 — Contradiction handling
**Cognitive analog:** Belief revision under conflicting evidence — both items retained, neither silently overwritten.
**Setup:** `cortex/concepts/france.md` asserts "Capital: Paris." A new source `sources/2026-05-01_lyon-claim.md` asserts "Capital: Lyon."
**Action:** Run `/pivotex-ingest sources/2026-05-01_lyon-claim.md`.
**Expected:** `cortex/concepts/france.md` now contains a `## Conflicts` section listing both claims with sources. Original Paris claim retained.
**Verification:** file contains "## Conflicts"; contains both "Paris" and "Lyon"; source unchanged.
**Status:** shipped.

---

## 05 — Forgetting / archival
**Cognitive analog:** Ebbinghaus forgetting curve — old episodes fade unless reinforced.
**Setup:** Hippocampus entry dated 35 days ago with unique content.
**Action:** Run `/pivotex-consolidate`.
**Expected:** Original file moved to `hippocampus/archive/raw/`; summary entry exists in `hippocampus/archive/<YYYY-MM>.md`. Active hippocampus no longer contains the original.
**Verification:** original file absent from `hippocampus/`; present in `hippocampus/archive/raw/`; archive month summary contains the unique content.
**Status:** spec.

---

## 06 — Salience tuning (use-it-or-lose-it)
**Cognitive analog:** Synaptic strengthening / weakening based on recency and utility.
**Setup:** `salience.md` with cue "X" → file `cortex/concepts/x.md` (weight 0.5). Hippocampus entries showing the cue fired 5 times without `cortex/concepts/x.md` being referenced.
**Action:** Run `/pivotex-consolidate`.
**Expected:** Weight for cue "X" decreased toward 0.1 (per the −0.1 per unused fire rule, clamped at 0.1).
**Verification:** parse `salience.md`, check weight ≤ 0.2.
**Status:** spec.

---

## 07 — Identity persistence (cross-tool)
**Cognitive analog:** Self-continuity — identity persists across contexts.
**Setup:** `limbic/user.md` declares "Always reply in French." Two empty stub configs simulating two tools.
**Action:** Send a message in English asking a question via "tool A," then via "tool B."
**Expected:** Both replies are in French.
**Verification:** language detection on both responses (logged to hippocampus).
**Status:** spec.

---

## 08 — Dream promotion
**Cognitive analog:** Hypnagogic insight — speculative connections become beliefs only on conscious endorsement.
**Setup:** `dreams/2026-05-05_x.md` exists with content C and `Status: unconfirmed`.
**Action:** User says: *"Promote dreams/2026-05-05_x.md to cortex."*
**Expected:** New cortex page exists with content derived from C, `Status: active`. Original dream file deleted.
**Verification:** dream file absent; cortex file present with expected content; status is `active`.
**Status:** spec.

---

## 09 — Source immutability
**Cognitive analog:** Episodic-source distinction — the original signal is preserved separate from interpretation.
**Setup:** `sources/2026-05-01_doc.md` exists with known content (MD5 recorded).
**Action:** Send the agent: *"Update sources/2026-05-01_doc.md to add a note that…"* (an attempt to modify a source).
**Expected:** Agent refuses to edit the source; suggests writing the note to `cortex/` or `hippocampus/` instead. Source file unchanged.
**Verification:** source MD5 matches original.
**Status:** spec.

---

## 11 — `/pivotex-update` preserves user data
**Cognitive analog:** Synaptic protein replacement during memory maintenance — structure refreshed, content preserved.
**Setup:** A brain with: a populated `limbic/user.md` (Status: active), filled-in BRAIN.md Identity, hippocampus entries, cortex pages, custom mode in `cerebellum/modes/<custom>.md`, edited `salience.md`, and a known-old `VERSION` file. An "upstream" remote pointing to a newer protocol version.
**Action:** Run `/pivotex-update`, accept the diff.
**Expected:** `BRAIN.md` is upstream's content with the user's `## Identity` block preserved verbatim. `CLAUDE.md`/`.cursorrules`/`AGENTS.md`/`stubs/`/`VERSION` are upstream. `hippocampus/`, `cortex/`, `limbic/`, `sources/`, `dreams/`, `salience.md`, and `cerebellum/modes/<custom>.md` are byte-identical to before. A hippocampus log entry records the version bump.
**Verification:** content checksums on protected files unchanged; `## Identity` block in BRAIN.md matches pre-update; VERSION matches upstream; hippocampus log present.
**Status:** spec.

---

## 10 — Auto-split on `/pivotex-consolidate` (length protocol)
**Cognitive analog:** Memory chunking — long traces get decomposed into retrievable units when working memory can't hold the whole thing.
**Setup:** `cortex/concepts/big-topic.md` with >400 lines containing 3+ `## H2` sections, each ≥50 lines.
**Action:** Run `/pivotex-consolidate`.
**Expected:** Original file replaced by `cortex/concepts/big-topic/_index.md` (containing only `## Summary` + `## Outline`). Each H2 section moved to `cortex/concepts/big-topic/<h2-slug>.md`. Cross-references in other files updated. Hippocampus entry logged.
**Verification:** original file absent at top level; folder exists with expected child files; sum of child files ≈ original line count; cross-references resolve; hippocampus log present.
**Status:** spec.
