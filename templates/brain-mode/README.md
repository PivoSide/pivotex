# My PIVOTEX Brain

A persistent, brain-shaped memory for my AI agents — plain markdown, cross-platform, mine.

This folder is now active. The agent reads [`BRAIN.md`](BRAIN.md) every session and follows the protocol there.

---

## Quick reference

### Regions

| Folder | What lives here |
|---|---|
| `BRAIN.md` | The protocol. Read first, every session. |
| `hippocampus/` | Daily notes (episodic). What happened, when. |
| `cortex/` | Topic pages (semantic). What's known, cross-linked. |
| `cerebellum/` | Workflows and modes (procedural). |
| `limbic/` | User profile, agent identity, feedback. |
| `salience.md` | Cue → memory map. Drives selective attention. |
| `sources/` | Raw documents. Immutable — never edited. |
| `dreams/` | Speculative connections. Promote or delete. |
| `stubs/` | Per-tool config snippets for connecting other projects to this brain. |

### Operations

Type these in chat — the agent runs them per [`BRAIN.md`](BRAIN.md):

| Op | Purpose |
|---|---|
| `/pivotex-ingest <path>` | Process a new source into cortex with citations. |
| `/pivotex-consolidate` | Weekly sleep pass: replay, promote patterns, tune salience, archive. |
| `/pivotex-lint` | Read-only audit for contradictions, dead links, stale entries. |
| `/pivotex-dream` | Generate speculative connections for review. |
| `/pivotex-forget <path>` | Intentional removal with a tombstone. |

### Modes

Detected from your message intent:
- **plan** — design discussions
- **build** — implementation
- **debug** — broken things
- **research** — learning
- **casual** — default, light load

---

## Day-to-day

- **Talk freely.** The agent writes to `hippocampus/`, `limbic/`, `cerebellum/` per the routing rules.
- **Drop documents in `sources/`** and ask `/pivotex-ingest <path>`. Cortex grows automatically with citations.
- **Run `/pivotex-consolidate` weekly.** Patterns get promoted; old episodes get archived.
- **Run `/pivotex-dream` when curious.** Surprise connections, low cost.
- **Edit anything by hand.** It's all markdown. If a cortex page is wrong, fix it.

---

## Using the brain from other tools

The root contains `CLAUDE.md`, `.cursorrules`, and `AGENTS.md` (brain-mode). Cursor, Codex, and Claude Code pick them up automatically when this folder is opened.

To point a *different project's* folder at this brain:

```bash
# Inside the other project:
cp <brain-root>/stubs/CLAUDE.md      ./CLAUDE.md
cp <brain-root>/stubs/.cursorrules   ./.cursorrules
cp <brain-root>/stubs/AGENTS.md      ./AGENTS.md
# Then replace <BRAIN_ROOT> in each stub with the absolute path to this folder.
```

For a custom API agent: paste `stubs/system-prompt.txt` into the system prompt and replace `<BRAIN_ROOT>`.

---

## Maintenance

- **`limbic/user.md` and `limbic/self.md`** — review monthly, prune drift.
- **`salience.md`** — `/pivotex-consolidate` tunes weights over time; hand-edit when a pattern is obvious.
- **`sources/`** — append-only. Never edit a source already there.
- **`dreams/`** — review periodically. Promote to cortex or delete.
- **`hippocampus/`** — `/pivotex-consolidate` archives entries older than 30 days. Don't worry about volume.

---

## Privacy and ownership

This is your brain. The default `.gitignore` excludes:
- `hippocampus/2*.md` (your daily notes)
- `dreams/*` (your speculations)
- `sources/*` (your private documents)
- Optionally `limbic/user.md` (uncomment in `.gitignore` if you want)

Push to a private repo if you want backup; keep it local-only if you'd rather. Your call.

---

## Pulling upstream protocol updates

When the upstream PIVOTEX template ships protocol changes, ask your agent:

```
/pivotex-update
```

The agent fetches the latest, surgically merges the protocol files (preserving your `## Identity` block in `BRAIN.md`), shows you a diff, and waits for your confirmation before committing. Your data is never touched: `hippocampus/`, `cortex/`, `limbic/`, `sources/`, `dreams/`, and `salience.md` are protected by the operation's contract.

The current protocol version is in the `VERSION` file at the brain root.

Don't run `init-brain.sh` again — it self-deleted after activation. Re-running it (from a fresh template clone) would overwrite your customizations.

---

## License

MIT. See [`LICENSE`](LICENSE).
