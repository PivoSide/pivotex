# Manual end-to-end checklist

Layered verification stops here, at scenarios only a human can judge: "did the brain actually work?" Each scenario takes 2–10 minutes. Run before a release or when you've changed routing/operations/onboarding.

## Prerequisites

- A clean clone of PIVOTEX in a new folder.
- Claude Code installed (or another supported tool).
- Run `bash tests/preflight.sh` and `bash tests/test-init.sh` first — they catch the cheap failures so you don't waste a session debugging structural breakage.

---

## Scenario 1 — Fresh clone → init → onboarding (5 min)

Verifies: init script + brain-mode files + Onboarding flow.

1. `git clone <repo> ~/scenario1-brain`
2. `cd ~/scenario1-brain`
3. `bash init-brain.sh` (or `pwsh init-brain.ps1`) — confirm `y`
4. Verify console output mentions: replaced root files, removed maintainer artifacts, reset git.
5. Open Claude Code: `claude`
6. Type: `hi`

**Expected:** the agent identifies it's the first session, runs the Onboarding flow from `BRAIN.md`. Asks: name → languages → work type → comm preferences → 1–3 goals.

7. Answer the questions.

**Verify after:**
- [ ] `limbic/user.md` is filled in. `Status:` is now `active`.
- [ ] `BRAIN.md` Identity section has owner name + brain-root path + today's date filled.
- [ ] `hippocampus/<today>.md` exists with one entry: "Onboarded — set up profile, ready to work."
- [ ] Agent's reply confirms setup is complete.

---

## Scenario 2 — Single-session brain mode (3 min)

Verifies: routing rules, hippocampus logging, feedback writes.

1. Continue the same session from Scenario 1 (or open a fresh one).
2. Tell the agent: *"By the way, always use bullet points in your replies — long paragraphs are hard to skim."*

**Expected:** agent acknowledges, mentions saving the preference.

3. Tell the agent: *"I'm working on a project called <something>. The deadline is next month."*

**Expected:** agent acknowledges, mentions logging.

**Verify after:**
- [ ] `limbic/feedback/<topic>.md` (or appended entry) exists with the bullet-points preference, including a **Why:** and **How to apply:** section.
- [ ] `cortex/entities/<project-name>.md` OR an entry in `hippocampus/<today>.md` reflects the project + deadline.
- [ ] `sources/` is unchanged.

---

## Scenario 3 — Document ingest (5 min)

Verifies: `/pivotex-ingest`, citations, source immutability.

1. Drop a real document in `sources/` named `YYYY-MM-DD_<slug>.md`. (Use any markdown file with structured info — a paper summary, meeting notes.)
2. Note the file's content (or hash it: `sha256sum sources/<file>`).
3. Tell the agent: `/pivotex-ingest sources/<filename>`

**Expected:** agent confirms ingesting, processes the source, creates/updates cortex pages.

**Verify after:**
- [ ] At least one file under `cortex/concepts/` or `cortex/entities/` references the source: `(see sources/<filename>)`.
- [ ] The source file's content (or hash) is **unchanged**.
- [ ] `hippocampus/<today>.md` has a one-line entry mentioning the ingest.

---

## Scenario 4 — Multi-day consolidation (8 min)

Verifies: `/pivotex-consolidate`, pattern promotion, salience tuning.

1. Manually create three backdated entries in `hippocampus/`:
   - `hippocampus/2026-04-29.md`, `2026-04-30.md`, `2026-05-01.md`
   - Each mentions a recurring decision (e.g., "use SQLite for local data," "deploy via PivoCloud," etc.)
2. Tell the agent: `/pivotex-consolidate`

**Expected:** agent reads the entries, finds the pattern, promotes it.

**Verify after:**
- [ ] A new `cortex/concepts/<topic>.md` page exists (or an existing one is updated).
- [ ] The cortex page references at least one of the hippocampus dates.
- [ ] `salience.md` has a new or updated cue pointing at the new cortex page.
- [ ] Original hippocampus entries are unchanged (under 30 days old).
- [ ] `hippocampus/<today>.md` has a one-line entry summarizing what was consolidated.

---

## Scenario 5 — Cross-tool persistence (5 min)

Verifies: identity travels across tools.

1. Open a different tool (Cursor or Codex) in the same brain folder.
2. Type: `hi`

**Expected:** the agent reads `.cursorrules` (or `AGENTS.md`), follows `BRAIN.md`, sees `limbic/user.md` is **already populated** (not `needs-setup`), greets you by name, doesn't run onboarding again.

3. Ask: *"What do you remember about me?"*

**Expected:** agent recalls name, languages, communication preferences, current goals — sourced from `limbic/user.md`.

**Verify after:**
- [ ] No new onboarding ran.
- [ ] `hippocampus/<today>.md` has an entry from this session (in addition to any prior entries).

---

## Scenario 6 — Maintainer mode (template repo) (3 min)

Verifies: maintainer-mode root files prevent brain behavior in the un-inited template.

1. In a separate clone of PIVOTEX (no init):
   - `git clone <repo> ~/scenario6-maintainer`
   - `cd ~/scenario6-maintainer` (do NOT run init)
2. Open Claude Code: `claude`
3. Type: `hi`

**Expected:** the agent recognizes maintainer mode (per root `CLAUDE.md`). It does NOT run onboarding. It might say something like: *"This is the PIVOTEX template repo. I'm in maintainer mode. Are you here to edit the protocol/tests/docs?"*

4. Ask: *"What's the routing rule for corrections?"*

**Expected:** agent answers from `BRAIN.md` content like a coding agent would — no logging to `hippocampus/`, no writes to `limbic/`.

**Verify after:**
- [ ] No `hippocampus/<today>.md` was created.
- [ ] `limbic/user.md` still has `Status: needs-setup`.
- [ ] No new files in `limbic/feedback/`.

---

## Scenario 7 — Dream loop (5 min)

Verifies: `/pivotex-dream`, dream lifecycle (unconfirmed → promoted/rejected).

1. Use a brain that's been running for at least a week (run scenarios 1–4 first, OR fast-forward by populating hippocampus + cortex with seed content).
2. Tell the agent: `/pivotex-dream`

**Expected:** agent reads sampled hippocampus + cortex entries, writes a `dreams/<today>_<slug>.md` file with `Status: unconfirmed`, frames it as a hypothesis.

**Verify after:**
- [ ] A new file in `dreams/` exists with `Status: unconfirmed`.
- [ ] The file frames findings as "I noticed X and Y; could be related because Z."
- [ ] Nothing in `cortex/` was modified by `/pivotex-dream` directly.

3. Tell the agent: *"Promote that dream — it's right."*
4. Verify the dream content moved to `cortex/`, the dream file is deleted, and `Status:` is now `active` in cortex.

---

## When something fails

- **Scenarios 1–6 fail at "agent doesn't follow protocol"** → check the root `CLAUDE.md` / `.cursorrules` / `AGENTS.md` is being read by your tool. Re-open the project.
- **Scenario 1 fails at "no `<today>.md` created"** → routing rule for "Daily activity" might not match; check `BRAIN.md` Routing rules.
- **Scenario 3 fails at "citation missing"** → check `BRAIN.md` `/pivotex-ingest` operation step 3.
- **Scenario 4 fails at "pattern not promoted"** → check `BRAIN.md` `/pivotex-consolidate` operation step 2 ("3+ times across days").
- **Scenario 6 fails at "agent ran onboarding"** → maintainer-mode `CLAUDE.md` was overwritten or skipped. Restore from git.

## Recording results

Each scenario passes or fails. Note the result, paste any unexpected behavior to the issue tracker, link the brain-state diff if useful.
