# PIVOTEX

> A brain-shaped memory for AI agents. Plain markdown. Cross-platform. Ready to use.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)
![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen)

## Summary

PIVOTEX gives your AI agent a persistent brain that survives across tools, sessions, and platforms. It's not a database, not a vector store, not a framework — it's a folder of markdown files following a clear protocol that any agent can read, write, and learn from.

**Why a brain shape?** Human memory works in regions, each tuned for a different job. When agent memory is one undifferentiated blob, retrieval breaks down. PIVOTEX maps that biology onto folders: `hippocampus/` for what happened, `cortex/` for what's known, `cerebellum/` for how to work, `limbic/` for who you are.

**Why markdown?** You can read it. You can edit it. You own it. It works in every tool. When the agent gets something wrong, you fix it with a text editor. When you switch from Claude to Cursor to a custom GPT agent, the brain comes with you.

---

## Table of contents

- [How it feels to use](#how-it-feels-to-use)
- [Quick start](#quick-start)
- [Mental model](#mental-model)
- [What makes it brain-like](#what-makes-it-brain-like)
- [Cross-platform setup](#cross-platform-setup)
- [Operations](#operations)
- [Testing](#testing)
- [Customization](#customization)
- [What's deliberately not included](#whats-deliberately-not-included)
- [Compared to other approaches](#compared-to-other-approaches)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

---

## How it feels to use

You open a new session in any tool. You say: *"Help me think about how to ship the side-project."*

Behind the scenes:

1. The agent reads `BRAIN.md` (always).
2. Loads its priming set: today's notes, recent activity, your profile, the salience map.
3. Scans your message. Cues match `"ship"` and `"side-project"` → loads the relevant cortex pages and the shipping workflow from cerebellum.
4. Replies with full context: your preferences, project state, your usual workflow, recent decisions.
5. After the session: appends to today's hippocampus entry.
6. Sunday: you run `/pivotex-consolidate`. The session promotes a durable insight to a new cortex page. Salience weights update for what was useful.

You never told it what to load. It loaded the right things because the cues, the weights, and consolidation *taught it* what's relevant.

---

## Quick start

```bash
# 1. Clone the template
git clone https://github.com/PivoSide/pivotex.git ~/my-brain
cd ~/my-brain

# 2. Activate as a brain (one-time, deterministic)
bash init-brain.sh           # Linux/macOS
# or
pwsh init-brain.ps1          # Windows
```

The init script does this in one shot — no per-step prompts, just one confirmation at the start:

- Replaces the maintainer-mode `CLAUDE.md` / `.cursorrules` / `AGENTS.md` / `README.md` at the root with **brain-mode versions** (from `templates/brain-mode/`).
- Sets the brain root path in `BRAIN.md`.
- **Removes all maintainer artifacts:** `tests/`, `docs/`, `CONTRIBUTING.md`, `templates/`. You won't need them — they're for people developing PIVOTEX itself.
- **Resets git history** to a single `Initial brain commit`. Your brain starts with a clean ledger.
- Self-deletes (`init-brain.sh` and `init-brain.ps1` removed).

```bash
# 3. Open Claude Code in this folder
claude
```

Say hi. The brain-mode `CLAUDE.md` / `GEMINI.md` tells the agent to read `BRAIN.md`, see `limbic/user.md` has `Status: needs-setup`, and run the **Onboarding flow**:

> *"This is your first session in this PIVOTEX brain. Let me ask a few questions so I can remember who you are across sessions."*

It asks your name, languages, work type, communication preferences, and 1–3 goals. Your answers fill `limbic/user.md` and the Identity section of `BRAIN.md`. **Setup done.**

From here on, just talk:
- The agent writes to `hippocampus/`, `limbic/`, `cerebellum/` per the routing rules.
- Drop documents into `sources/` and ask `/pivotex-ingest <path>`.
- After ~7 days, ask `/pivotex-consolidate`.
- When curious, ask `/pivotex-dream`.

### Why a script and not auto-detection?

Every other approach (mode detection from first message, flag files, etc.) requires the agent or the system to *guess* whether you're using or maintaining the brain. The init script makes that decision **deterministic and one-time**: before init you're maintaining the template; after init, it's a brain. No guessing, no false positives.

### Using the brain from other tools

After init, the root `CLAUDE.md` / `.cursorrules` / `AGENTS.md` are the brain-mode versions — Cursor and Codex/Copilot pick them up automatically when they open the folder.

To point a *different project's* folder at this brain (so the brain follows you everywhere), copy a stub from `stubs/`:

```bash
# Inside the other project:
cp <brain-root>/stubs/CLAUDE.md      ./CLAUDE.md
cp <brain-root>/stubs/GEMINI.md      ./GEMINI.md
cp <brain-root>/stubs/.cursorrules   ./.cursorrules
cp <brain-root>/stubs/AGENTS.md      ./AGENTS.md
# Then replace <BRAIN_ROOT> in each stub with the absolute path to your brain folder.
```

For a custom API agent: paste `stubs/system-prompt.txt` into the system prompt and replace `<BRAIN_ROOT>`.

### Maintaining the template (you, the publisher / contributor)

If you've cloned this repo to *develop PIVOTEX itself* (not to use a brain), **don't run init** — that converts the template into a brain. The root files in the un-inited template are maintainer-mode: they tell the agent to behave as a coding agent and not run onboarding or write to memory regions. Edit, run tests, commit, push — like any normal repo.

Read [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the contributor workflow, [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) for the design rationale, and [`docs/EXTENDING.md`](./docs/EXTENDING.md) for concrete extension recipes.

---

## Mental model

Eight folders. Each mimics a biological function — the names tell you how the region *behaves*.

| Region | Function | Behavior |
|---|---|---|
| `BRAIN.md` | Brainstem / bootstrap | Tiny, always loaded first. Contains the protocol itself. |
| `hippocampus/` | Episodic | Append-only daily notes. Fades after 30 days via consolidation. |
| `cortex/` | Semantic | Topic pages, cross-linked. Built by consolidation, not direct writes. |
| `cerebellum/` | Procedural | Workflows the agent follows. |
| `limbic/` | Affective | User profile, agent identity, feedback, salience-weighted preferences. |
| `salience.md` | Attention | Cue → memory map. Drives selective context loading. |
| `sources/` | Raw evidence | Immutable. Never edited. |
| `dreams/` | Speculative | Unconfirmed connections. User reviews and promotes/rejects. |

See [`BRAIN.md`](./BRAIN.md) for the full protocol: startup ritual, routing rules, conventions, and operations.

---

## What makes it brain-like

PIVOTEX isn't a metaphor draped over a blob store — the architecture *enforces* brain-like behavior:

- **Selective attention.** A `salience.md` map of cues → memories means the agent loads only what's relevant to your current message. No vector DB needed; the rules are human-editable.
- **Episodic vs semantic separation.** Hippocampus holds *what happened*; cortex holds *what's known*. Consolidation promotes patterns from the first to the second over time.
- **Sleep cycle.** `/pivotex-consolidate` replays recent days, finds repeated patterns, strengthens useful cues, decays unused ones, archives old episodes, and lints for contradictions.
- **Constructive recall.** When the agent answers, it reconstructs from the loaded pieces — it doesn't dump files verbatim.
- **Dreams.** `/pivotex-dream` looks for non-obvious connections you didn't ask for. Promote the good ones, delete the rest. (This is the default-mode-network move.)
- **Forgetting.** Memory decays. Things you don't reinforce drop in salience. This is a feature, not a bug.
- **Identity persists.** `limbic/self.md` gives the agent a voice that travels across tools and sessions.

---

## Cross-platform setup

The brain lives in one folder. Every tool gets a tiny stub pointing there.

| Tool | Where the stub goes | File |
|---|---|---|
| Claude Code | `<project>/CLAUDE.md` (or global) | `stubs/CLAUDE.md` |
| Gemini CLI | `<project>/GEMINI.md` | `stubs/GEMINI.md` |
| Cursor | `<project>/.cursorrules` | `stubs/.cursorrules` |
| Codex CLI / Copilot agents | `<project>/AGENTS.md` | `stubs/AGENTS.md` |
| OpenAI API / custom agent | system prompt | `stubs/system-prompt.txt` |

Replace `<BRAIN_ROOT>` in each stub with the absolute path to your brain folder. Done.

**The brain is portable. The shells are disposable.**

---

## Operations

Six slash-operations the agent runs (defined fully in [`BRAIN.md`](./BRAIN.md)):

| Op | Purpose |
|---|---|
| `/pivotex-ingest <path>` | Process a new source into cortex with citations |
| `/pivotex-consolidate` | Weekly sleep pass: replay, promote, tune, archive, lint |
| `/pivotex-lint` | Read-only audit for contradictions, dangling links, stale entries |
| `/pivotex-dream` | Generate speculative connections for review |
| `/pivotex-forget <path>` | Intentional removal with a tombstone in the original location |
| `/pivotex-update` | Pull latest protocol from upstream without touching user data |

These are *instructions to the agent*, not shell commands. Type them in chat and the agent follows the protocol in `BRAIN.md`.

---

## Testing

> **Note for users:** `tests/` is removed by `init-brain.sh`. This section is relevant to *maintainers* and *contributors* working on the un-inited template repo.

PIVOTEX ships with a deterministic test suite modeled on cognitive memory experiments. Each test mirrors a phenomenon from human memory research (cued recall, consolidation, source attribution, contradiction handling, forgetting) applied to the protocol.

The agent's reasoning is non-deterministic; the **brain-state verification is**. Tests assert on file existence, content, and immutability — not on LLM output.

```bash
# Linux / macOS
bash tests/run.sh 02-consolidation

# Windows
pwsh tests/run.ps1 -TestId 02-consolidation
```

The runner sets up a sandbox brain, prints the action to perform, waits for you, then runs assertions. See [`tests/README.md`](./tests/README.md) and [`tests/cognitive-memory-tests.md`](./tests/cognitive-memory-tests.md).

Currently shipped fixtures: `02-consolidation`, `03-source-citation`, `04-contradiction`. Other tests are speced — see [`docs/EXTENDING.md`](./docs/EXTENDING.md#adding-a-new-test) for how to add fixtures.

---

## Customization

The Onboarding flow handles `limbic/user.md` and the Identity section of `BRAIN.md` automatically on first session — you don't need to edit those by hand.

What you may want to tune later:

1. **`limbic/self.md`** — the agent's voice and boundaries. Edit if the default tone doesn't fit you.
2. **`salience.md`** — cue → memory map. `/pivotex-consolidate` tunes weights over time, but you can hand-edit anytime.
3. **`cerebellum/modes/`** — add new modes for your workflows (e.g., `pr-review.md`, `deploy.md`, `writing.md`).
4. **`stubs/*`** — only matters if you're pointing *other projects* at this brain. Replace `<BRAIN_ROOT>` with the absolute path.

To re-run onboarding (e.g., after a major identity change), set `Status: needs-setup` at the top of `limbic/user.md` and start a new session.

If you fork PIVOTEX to publish your own customized template, `.gitignore` already excludes user-data folders (`hippocampus/2*.md`, `dreams/`, `sources/*`). Adjust to taste.

---

## What's deliberately not included

- **No vector database.** Markdown grep + the salience map handle 95% of retrieval. You can layer embeddings on top later — the files don't change.
- **No formal knowledge graph.** Cross-references via `[[wiki-links]]` are enough. A graph emerges from the links naturally.
- **No multi-agent orchestration.** One user, one brain. Sharing a brain across agents is possible; it's not the focus.
- **No required automation.** The slash-ops are manual until you feel friction. Add hooks/cron when you want to.
- **No dependencies.** It's a folder of markdown. There is nothing to install.

---

## Compared to other approaches

PIVOTEX stands on shoulders. Credit where it's due:

- **Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** — the source/wiki/schema layering and the "stop re-deriving, start compiling" insight. PIVOTEX uses this pattern for `sources/`, the consolidation cycle, and the citation discipline.
- **Jason-Cyr's [ai-shared-brain](https://github.com/Jason-Cyr/ai-shared-brain)** — the identity layer and the startup ritual. PIVOTEX adopts this for `limbic/` and `BRAIN.md`.
- **Claude Code's auto-memory** — the typed-memory taxonomy (user / feedback / project / reference). PIVOTEX maps these onto `limbic/`.

**What PIVOTEX adds:** the biological region metaphor (with enforced behavioral differences per region), the salience map for selective attention, the explicit consolidation cycle (sleep), the dreams loop, and a single-bootstrap cross-platform protocol.

**What PIVOTEX is not:** a scalable team wiki, a research-grade knowledge management system, or a replacement for embeddings if you have millions of memories. For personal-to-small-team agents, it's the simplest thing that could possibly work — and it feels brain-like in practice.

---

## FAQ

**Q: Does the agent learn from conversation?**
Yes. Every session appends to `hippocampus/`. Corrections go to `limbic/feedback/`. Preferences update `limbic/user.md`. Procedures land in `cerebellum/`. Patterns across days get promoted to `cortex/` by `/pivotex-consolidate`.

**Q: Does the agent learn from documents?**
Yes. Drop files into `sources/`, run `/pivotex-ingest`. The agent extracts entities, claims, and concepts into cortex pages with citations back to the source. Sources stay immutable so the citations never rot.

**Q: Will the brain bloat over time?**
`/pivotex-consolidate` archives stale hippocampus entries and decays unused salience cues. `/pivotex-lint` flags orphaned and contradictory items. `/pivotex-forget` removes things explicitly. Maintenance is on you, but the tools are there.

**Q: Can two agents share a brain?**
Yes — point them at the same path. Last-write-wins on the file level. Multi-agent isn't the design focus, but nothing blocks it.

**Q: Why not a vector database?**
Because then *you* can't read it. The whole point is auditability and ownership. If you have so many memories that grep + salience can't handle it, layer embeddings *over* the same files — the markdown stays the source of truth.

**Q: What if my agent doesn't follow the protocol?**
The protocol lives in `BRAIN.md`. If the agent skips steps, your tool's stub isn't being read. Check your `CLAUDE.md` / `.cursorrules` / system prompt is in place and the `<BRAIN_ROOT>` path is correct.

**Q: Does this work without internet?**
Yes. It's local files. Whatever LLM your agent uses needs whatever it needs, but PIVOTEX itself is offline.

**Q: Is this for individuals or teams?**
Designed for individuals. Teams can share a brain via git, but conflict resolution is on you. Multi-agent and concurrent-edit support are not features.

---

## Roadmap

PIVOTEX is intentionally minimal. Possible additions (not committed):

- An `/inspect <topic>` op that returns just the relevant cortex pages without LLM synthesis.
- Tool-specific automation recipes (Claude Code hooks for auto-`/pivotex-consolidate`, cron jobs).
- A lightweight web viewer for browsing the brain.
- Example brains for common archetypes (developer, researcher, writer).
- More fixtures for the cognitive-memory test suite (tests 01, 05, 06, 07, 08, 09 are speced but unfixtured — see [`tests/cognitive-memory-tests.md`](./tests/cognitive-memory-tests.md)).

PRs welcome — open an issue first for substantive proposals. See [`CONTRIBUTING.md`](./CONTRIBUTING.md).

---

## Contributing

PIVOTEX is opinionated and small. Contributions are very welcome — bug fixes, new tests, new modes, documentation improvements, cross-platform fixes.

Read these before opening a PR:

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — entry point: dev setup, scope, style, commit conventions, PR workflow.
- [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) — the *why* behind the design. Read this before proposing protocol changes.
- [`docs/EXTENDING.md`](./docs/EXTENDING.md) — concrete recipes (add a mode, add an operation, add a test, add a region).
- [`tests/README.md`](./tests/README.md) — test philosophy and how to run the suite.

Open an issue before substantive changes.

---

## License

[MIT](./LICENSE). Use it, fork it, customize it. If you publish a fork, scrub any personal data first.

---

## Credits

- The brain-region metaphor draws from standard neuroscience models (hippocampus / cortex / cerebellum / limbic / brainstem).
- The wiki-pattern and ingest workflow are adapted from **Andrej Karpathy**'s LLM Wiki gist.
- The identity layer and startup-ritual concept are inspired by **Jason Cyr**'s `ai-shared-brain`.
- The typed-memory taxonomy mirrors **Claude Code**'s auto-memory system.

Built and shaped through conversation. The brain you're reading right now was scaffolded by an agent following the same protocol it now serves.
