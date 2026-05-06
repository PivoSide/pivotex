# PIVOTEX — agent memory architecture
Status: active
Last updated: 2026-05-06
Sources: conversation 2026-05-06

## Summary
Brain-shaped, file-native, agent-agnostic memory. Six functional regions modeled on biology, plus immutable sources and speculative dreams. Markdown only. Selective context loading via cue→memory salience map. Compounds via periodic consolidation.

## Regions and their behavior
- **Brainstem** (`BRAIN.md`) — tiny always-on bootstrap. Identity + protocol.
- **Hippocampus** — episodic, append-only, time-indexed. Fades after 30d via consolidation.
- **Cortex** — semantic, cross-linked, built by consolidation (never written directly during conversation).
- **Cerebellum** — procedural workflows.
- **Limbic** — user/self identity, salience-weighted preferences and feedback.
- **Salience** — cue→memory map, drives selective attention.
- **Sources** — immutable raw evidence (Karpathy layer 1).
- **Dreams** — speculative connections, unconfirmed until user promotes.

## Three retrieval signals
1. **Static priming** — always loaded (BRAIN, today's hippocampus, _last7days, salience, limbic).
2. **Cued retrieval** — message scanned for cues, salience map fires, matched files load.
3. **Mode loading** — task type (plan/build/debug/research/casual) loads its cerebellum procedure.

## Consolidation cycle (the "sleep")
Weekly or on demand. Replays hippocampus → promotes patterns to cortex → tunes salience weights → archives old episodes → lints contradictions.

## Cross-platform
One bootstrap (`BRAIN.md`), three-line stubs per tool (CLAUDE.md / .cursorrules / AGENTS.md / system-prompt). Brain stays put; tool shells adapt.

## What's deliberately out
- No vector DB — markdown grep + salience cues handle 95% of retrieval.
- No formal knowledge graph — cross-references via `[[wiki-links]]` are enough.
- No multi-agent — one user, one brain.
- No required automation — slash-ops are manual until automation pain emerges.

## Why it feels human
- All readable, anytime.
- It forgets (hippocampus fades unless promoted).
- It surprises (`/pivotex-dream` finds connections you didn't ask for).
- It has a voice (`limbic/self.md` persists across tools).
- It admits uncertainty (`Status:` field, salience weights).
- It compounds (every `/pivotex-consolidate` makes the next session smarter).

## Connections
- [[BRAIN.md]]
- [[cerebellum/modes/plan.md]]
- [[salience.md]]
