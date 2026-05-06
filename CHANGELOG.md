# Changelog

All notable changes to PIVOTEX are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):
`feat` → minor bump · `fix` / `chore` → patch bump · breaking changes → major bump.

---

## [1.1.0] — 2026-05-06

### Added
- **Gemini CLI support** — `GEMINI.md` stub and brain-mode template; `init-brain.sh` / `init-brain.ps1` now place it at the brain root on activation.
- **Gemini operations hint table** — intent → operation mapping in both `stubs/GEMINI.md` and `templates/brain-mode/GEMINI.md` so Gemini proactively offers the right operation without requiring exact slash commands.
- **Claude Code tab-completable slash commands** — `stubs/claude-commands/` with one `.md` file per operation; `init-brain.sh` / `init-brain.ps1` copy them to `.claude/commands/` on activation; `/pivotex-update` now installs them automatically on future updates.
- **GitHub repo polish** — version / license / platform / no-deps badges in README; issue templates (bug report, feature request); PR template; repo description and topics set on GitHub.

### Fixed
- **Windows PowerShell compatibility** — removed `&&`, `||`, `2>/dev/null`, and `/tmp` paths from `BRAIN.md`'s `/pivotex-update` shell snippets; they now use platform-agnostic prose. `GEMINI.md` gained a "Shell commands" section instructing Gemini to adapt syntax to the detected OS.
- **Clone URL** — README and CONTRIBUTING.md now point to `PivoSide/pivotex` instead of the placeholder `<you>/pivotex`.
- **`/pivotex-update` bootstrap gap** — step 10 added: update now installs `.claude/commands/` from `stubs/claude-commands/` so slash commands appear after any future update without manual intervention.

---

## [1.0.0] — 2026-05-06

Initial release of the PIVOTEX template.

### Included
- `BRAIN.md` — full protocol: startup ritual, routing rules, operations (`/pivotex-ingest`, `/pivotex-consolidate`, `/pivotex-lint`, `/pivotex-dream`, `/pivotex-forget`, `/pivotex-update`), conventions, length & decomposition rules.
- Eight memory regions: `hippocampus/`, `cortex/`, `cerebellum/`, `limbic/`, `sources/`, `dreams/`, `salience.md`.
- Cross-platform stubs: `CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `system-prompt.txt`.
- `init-brain.sh` / `init-brain.ps1` — one-shot deterministic activation script; replaces maintainer-mode files with brain-mode versions, resets git history, self-deletes.
- Brain-mode templates in `templates/brain-mode/`.
- Cognitive-memory test suite in `tests/` with fixtures `02-consolidation`, `03-source-citation`, `04-contradiction`.
- Architecture and extension docs in `docs/`.
