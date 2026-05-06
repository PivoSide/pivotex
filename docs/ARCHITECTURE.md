# Architecture

The *why* behind PIVOTEX. Read this before proposing protocol changes.

## Premise

LLMs have no memory between sessions. Every conversation starts fresh. PIVOTEX is **an external store + a protocol** an agent uses to read, write, and revise memory across sessions.

The interesting question isn't *what storage* — that's the easy part. It's *how should an agent know where to put a fact, what to load when, and what to forget*.

Most agent-memory systems fail not because the storage is wrong, but because:
- The agent doesn't know where to write something.
- The agent doesn't read what it wrote.
- Memories accumulate without ever being revisited or pruned.
- Two memories about the same thing exist in different places and drift.

PIVOTEX's design responds to those four failure modes directly.

---

## The cognitive memory map

Cognitive psychology distinguishes memory types that real human brains handle very differently. PIVOTEX maps onto them:

| Memory type | What it holds | Update frequency | Lifespan | PIVOTEX region |
|---|---|---|---|---|
| **Working** | Current conversation | Every turn | Minutes | The LLM context window |
| **Identity** | Self-model + user model | Slow | Years (drifts) | `limbic/self.md`, `limbic/user.md` |
| **Episodic** | What happened, when | Per session | Months → years | `hippocampus/` |
| **Semantic** | Facts about the world | When learned/corrected | Indefinite | `cortex/` |
| **Procedural** | How to do things | When refined | Indefinite | `cerebellum/` |
| **Source** | Raw evidence | Append-only | Forever | `sources/` |

Most agent-memory failures come from collapsing these into one bucket — a markdown junk drawer or a vector DB of "everything." Once they're separate, design choices become local: what's right for episodic isn't right for semantic.

---

## The eight regions

| Region | Behavior |
|---|---|
| `BRAIN.md` (brainstem) | Tiny, always-on bootstrap. Contains the protocol itself. |
| `hippocampus/` | Episodic. Append-only daily notes. Fades after 30 days via consolidation. Holds *what happened*. |
| `cortex/` | Semantic. Topic pages, cross-linked. **Built by consolidation**, not direct writes. Holds *what's known*. |
| `cerebellum/` | Procedural. Workflows the agent runs. Modes load from here. |
| `limbic/` | Affective. User profile, agent identity, feedback, salience-weighted preferences. |
| `salience.md` | Attention. Cue → memory map. Drives selective context loading. |
| `sources/` | Raw evidence. **Immutable.** Never edited. Citations point here. |
| `dreams/` | Speculative. Unconfirmed connections. User reviews and promotes/rejects. |

Each region has a *behavior contract* — append-only, immutable, built-by-consolidation, etc. Violating those contracts is what makes brains rot. The protocol enforces them.

---

## Three retrieval signals

Agents don't load everything every session. PIVOTEX layers three signals to bring back the right context:

1. **Static priming** (always loaded, ~1k tokens):
   - `BRAIN.md`, today's hippocampus, `_last7days.md`, `salience.md`, `limbic/self.md`, `limbic/user.md`.

2. **Cued retrieval** (loaded reactively):
   - The agent scans the user's message for cues.
   - `salience.md` maps cues → files with weights.
   - Matched files load.

3. **Mode loading** (loaded by intent):
   - Plan / build / debug / research / casual.
   - Loads the matching `cerebellum/modes/<mode>.md`.

The combination = **selective attention without machine learning**. You see exactly what's loaded, you can edit the rules, you can audit failures. No vector DB needed for personal-scale brains.

---

## The three load-bearing pieces

Storage format is *not* what makes a brain work. These three are:

### 1. Routing
When a new fact arrives, does the agent know *where* it belongs? Without an explicit decision rule, the agent guesses, and over time the categories blur.

PIVOTEX's routing table lives in `BRAIN.md`. Every input type maps to exactly one region.

### 2. Ritual
What gets read at session start, and what's loaded reactively? "Read everything" doesn't scale. "Read nothing unless asked" forgets.

PIVOTEX uses a small fixed *priming set* + cue-driven retrieval + mode loading.

### 3. Upkeep
Memory rots without revisits. Three jobs that never go away:
- **Supersession** — new fact replaces old (not just appends).
- **Lint** — scan for contradictions, dead links, stale state.
- **Forgetting** — intentional removal, not just accumulation.

PIVOTEX bundles these as `/pivotex-consolidate`, `/pivotex-lint`, and `/pivotex-forget`. Without naming who/when/how each runs, the brain becomes a hoarder's attic in 6 months.

---

## Tradeoff axes

Designing storage for any one memory type means picking a position on these axes:

- **Readable ↔ Retrievable** — humans skim prose; agents query embeddings.
- **Structured ↔ Flexible** — schemas catch errors; free-form captures nuance.
- **Authoritative ↔ Compounding** — immutable source of truth vs. evolving artifact.
- **Push ↔ Pull** — write at every event vs. write on demand.
- **Active ↔ Reactive** — agent maintains continuously vs. only when asked.

The mistake is picking one position globally. PIVOTEX picks per-region:

| Region | Authoritative ↔ Compounding | Readable ↔ Retrievable | Structured ↔ Flexible |
|---|---|---|---|
| `sources/` | Authoritative (immutable) | Readable | Flexible |
| `hippocampus/` | Compounding | Readable | Flexible |
| `cortex/` | Compounding | Both (citations + prose) | Structured |
| `cerebellum/` | Authoritative-ish (manually curated) | Readable | Structured |
| `limbic/` | Authoritative | Readable | Structured |

Different jobs, different positions. That's the architecture.

---

## What's deliberately out

These get refused on principle, not for now:

| Excluded | Why |
|---|---|
| Vector databases | You can't read them. The salience map handles cued retrieval at personal scale. |
| Formal knowledge graphs | Cross-references via `[[wiki-links]]` are enough. A graph emerges from the links. |
| Multi-agent orchestration | One user, one brain. The file format permits sharing, but it's not the focus. |
| Required automation | Slash-ops are manual until you feel friction. Hooks are *examples* in docs, not core. |
| Dependencies / daemons | It's a folder of markdown. Nothing to install. |
| Personal data in templates | The template repo must be safe to fork without scrubbing. |

The init script and the test runners are the only executable surface — both are pure shell, both self-contained.

---

## Cross-platform contract

PIVOTEX must work in **any agent** (Claude Code, Cursor, Codex/Copilot, ChatGPT-with-files, OpenAI API, Aider, custom):

1. **Plain files only** — markdown for content; SQLite optional later for indexing.
2. **One bootstrap, one path** — `BRAIN.md` at root. Every tool's stub points at it.
3. **The protocol lives in `BRAIN.md`, not in tool config** — switching tools means changing 3 lines, not the whole system.

This contract is non-negotiable. Contributions that break it (e.g., "let's add a Python helper for X") will be redesigned to stay markdown-only.

---

## Relationship to prior art

PIVOTEX stands on shoulders. Read the originals:

- **[Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** — sources / wiki / schema layering, the "stop re-deriving, start compiling" insight, ingest discipline. PIVOTEX uses this for `sources/`, `/pivotex-ingest`, and the citation requirement.
- **[Jason-Cyr's ai-shared-brain](https://github.com/Jason-Cyr/ai-shared-brain)** — identity layer (SOUL.md / USER.md / AGENTS.md), the startup ritual. PIVOTEX adopts this for `limbic/` and the "read these files first" pattern.
- **Claude Code's auto-memory** — the typed-memory taxonomy (`user` / `feedback` / `project` / `reference`). PIVOTEX maps these onto `limbic/`.

What PIVOTEX adds on top:
- The biological region metaphor with *behaviorally distinct* regions (not just folders).
- The salience map for selective attention.
- The explicit consolidation cycle (sleep) and dreams loop.
- A single-bootstrap cross-platform protocol with maintainer/brain-mode split.
- A deterministic activation script (`init-brain.sh`).
- A cognitive-memory-experiment-modeled test suite.

---

## What "feels human" means here

Not metaphor — enforced behavior:

- **All readable, anytime.** No black box.
- **Forgets unless reinforced.** Hippocampus fades. That's a feature.
- **Surprises you.** `/pivotex-dream` finds connections you didn't ask for.
- **Has a voice that travels.** `limbic/self.md` persists across tools.
- **Admits uncertainty.** `Status:` field, salience weights, `Conflicts` sections.
- **Compounds.** Every `/pivotex-consolidate` makes the next session smarter.

These aren't aesthetic claims; each maps to a specific region's contract or operation in the protocol.
