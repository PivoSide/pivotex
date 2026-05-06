# Contributing to PIVOTEX

Thanks for considering a contribution. PIVOTEX is a **protocol, not a framework** — most changes are small, principled, and reviewable in a single sitting.

This document is the entry point. For deeper material:
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — design rationale, the cognitive memory map, tradeoff axes
- [`docs/EXTENDING.md`](docs/EXTENDING.md) — concrete recipes (add a mode, add an operation, add a test, add a region)
- [`tests/README.md`](tests/README.md) — testing philosophy and contributor guide
- [`BRAIN.md`](BRAIN.md) — the canonical protocol reference

---

## Table of contents

- [Before you start](#before-you-start)
- [What changes are welcome](#what-changes-are-welcome)
- [What's outside scope](#whats-outside-scope)
- [Dev setup](#dev-setup)
- [Maintainer mode vs brain mode](#maintainer-mode-vs-brain-mode)
- [Running tests](#running-tests)
- [Style guidelines](#style-guidelines)
- [Commit messages](#commit-messages)
- [Pull request workflow](#pull-request-workflow)
- [Code of conduct](#code-of-conduct)

---

## Before you start

1. Read the [`README.md`](README.md) for usage.
2. Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the *why*.
3. Open an [issue](../../issues) before any non-trivial change. Disagreement is fine; surprise PRs that rewrite the protocol are not.

---

## What changes are welcome

| Category | Examples |
|---|---|
| **Bug fixes** | Typos, broken cross-references, scripts that misbehave on edge cases (paths with spaces, non-ASCII filenames, locked files), failing tests on certain platforms. |
| **Documentation** | Clarity improvements, missing examples, fixing factual errors, translations. |
| **New tests** | Cognitive-memory tests with seed fixtures and `checks.ps1`/`checks.sh` (see [`docs/EXTENDING.md`](docs/EXTENDING.md#adding-a-new-test)). |
| **New cerebellum modes** | `research-mode.md`, `writing-mode.md`, `debug-mode.md`, etc. |
| **Protocol refinements** | Routing-rule sharpening, new operations, better lint rules — *with rationale and test coverage*. |
| **Cross-platform fixes** | Windows / Linux / macOS parity for scripts, paths, and tests. |
| **Init script improvements** | Better error messages, more configurable, safer defaults. |

---

## What's outside scope

PIVOTEX is opinionated. These contributions will be politely declined:

- **Vector databases, embeddings, retrieval ML.** The whole point is that you can read your own brain. Layered embeddings as an *optional* index over the same files might be acceptable; the markdown stays the source of truth.
- **Multi-agent orchestration.** One user, one brain.
- **Frameworks, dependencies, daemons.** Stay markdown-only. The init script is shell-only and self-deletes — that's the limit.
- **Tool-specific automation that breaks the cross-platform contract.** Hooks, recipes, and integrations live as *examples* in docs, not as required machinery.
- **Templates with personal data.** Don't ship someone's name, email, or working setup baked into examples.
- **Aesthetic-only refactors.** Renaming files or restructuring folders without a clear behavior or documentation benefit.

When in doubt: open an issue and ask before writing the code.

---

## Dev setup

PIVOTEX has **no dependencies**. Just clone and edit.

```bash
git clone https://github.com/PivoSide/pivotex.git
cd pivotex
git checkout -b your-feature-branch
```

That's it. Markdown files, two shell scripts, no install.

---

## Maintainer mode vs brain mode

This repo can be in one of two states:

| State | Root `CLAUDE.md` / `.cursorrules` / `AGENTS.md` | Who | What the agent does |
|---|---|---|---|
| **Maintainer mode** (template repo, default) | Tells the agent: "you're maintaining the template, do NOT run onboarding or write to memory regions" | Contributors editing PIVOTEX itself | Behaves as a normal coding agent |
| **Brain mode** (after `init-brain.sh`) | Tells the agent: "you're operating a brain, follow `BRAIN.md`" | End users who cloned the template and ran init | Runs onboarding, logs to hippocampus, routes inputs |

> **Gemini CLI note:** `GEMINI.md` follows the same two-mode split. The maintainer-mode root `GEMINI.md` does not exist (Gemini CLI won't pick anything up). The brain-mode version is placed at the root by `init-brain.sh` / `init-brain.ps1` from `templates/brain-mode/GEMINI.md`. The stub for pointing other projects at the brain lives in `stubs/GEMINI.md`.

**As a contributor, you're in maintainer mode.** Do *not* run `init-brain.sh` on your fork — that converts the template into a brain. If you accidentally run it, restore from git.

The init script's job is to swap the root files (and a few other things) atomically when a user activates a brain. The two sets live in:
- Maintainer-mode files: `CLAUDE.md`, `.cursorrules`, `AGENTS.md` at root
- Brain-mode files: `templates/brain-mode/CLAUDE.md`, `.cursorrules`, `AGENTS.md`

When you change one, **always update the matching one** so they stay in sync where it makes sense (e.g., adding a new convention should appear in both).

---

## Running tests

PIVOTEX ships a deterministic test suite modeled on cognitive memory experiments.

```bash
# Linux / macOS
bash tests/run.sh 02-consolidation

# Windows
pwsh tests/run.ps1 -TestId 02-consolidation
```

The runner sets up a sandbox, prints the action to perform with your agent, waits for you, then runs assertions. See [`tests/README.md`](tests/README.md) for the full guide and [`docs/EXTENDING.md`](docs/EXTENDING.md#adding-a-new-test) for adding new tests.

Every PR that changes routing, operations, or conventions should include a test (or update one).

---

## Style guidelines

### Markdown
- Wrap freely; don't reflow other people's lines unnecessarily.
- Cross-references inside the brain regions: `[[cortex/concepts/x.md]]` style.
- Every memory file has a `Status:` header (`active`, `superseded-by [link]`, `uncertain`, `archived`, `forgotten`).
- Dense bullets > essays in `cortex/` pages. One-liners > paragraphs in `hippocampus/`.

### Shell scripts
- **bash + PowerShell parity** for every runnable script. Don't add a runner that only works on one platform.
- Quote paths. Use absolute paths in tests and fixtures.
- Use `set -e` in bash, `$ErrorActionPreference = "Stop"` in PowerShell.
- Test on both Windows and a POSIX system before merging when feasible. If you only have one, mark the PR `needs-cross-platform-check`.

### File naming
- `lowercase-with-dashes.md` (not `snake_case.md`).
- Test fixtures: `<NN>-<short-slug>/`, e.g., `04-contradiction/`.
- Sources: `<YYYY-MM-DD>_<short-slug>.<ext>`.
- Daily hippocampus entries: `<YYYY-MM-DD>.md`.

### Dates
Always absolute (`YYYY-MM-DD`). Never "yesterday," "last week," etc.

### Examples in templates and tests
Use the user's product (PivoCloud) or a neutral placeholder (`<your-paas>`). Never reference competitor PaaS platforms — see [`limbic/feedback/no-competitor-paas.md`](limbic/feedback/no-competitor-paas.md) for the rule and reasoning.

---

## Commit messages

Conventional-ish, scope-prefixed:

```
fix(brain): clarify routing rule for procedures
feat(tests): add fixture for salience decay (test 06)
docs(architecture): explain the consolidation cycle
refactor(init-brain): handle missing templates dir gracefully
chore(stubs): align AGENTS.md wording with CLAUDE.md
```

Scope is the area touched: `brain`, `tests`, `docs`, `stubs`, `init-brain`, `salience`, etc.

---

## Pull request workflow

1. **Issue first** for anything more than a typo. Describe the problem, propose the fix.
2. **Branch** off `main`. One concern per PR.
3. **Test.** Add a fixture if you changed behavior. Run the existing suite.
4. **Update docs.** If routing rules, operations, or conventions changed, update `BRAIN.md` *and* `docs/ARCHITECTURE.md` if relevant.
5. **PR description** should answer:
   - What changes?
   - Why? (link to issue)
   - How tested?
   - Any cross-platform concerns?
6. **Review.** Expect comments. PIVOTEX is opinionated; we'd rather iterate than merge fast.

---

## Code of conduct

Be kind. Be specific in feedback. Disagree on the design, not the person.

Issues and PRs that violate basic civility will be closed without discussion.
