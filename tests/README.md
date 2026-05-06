# PIVOTEX tests

Test the brain like a cognitive-memory experiment. Each test mirrors a classic phenomenon (cued recall, consolidation, forgetting, source attribution, contradiction handling) applied to PIVOTEX's protocol.

## How "deterministic" works here

The agent's reasoning is LLM-driven and not deterministic.
The brain-state verification **is** deterministic.

A test:
1. Sets up a sandbox brain with a known seed.
2. Tells you the action to perform with your agent.
3. Runs assertion checks against the resulting brain state — file existence, content matching, immutability of sources.

If every assertion passes, the protocol behaved correctly. If not, the failing assertion shows exactly where the agent diverged.

For maximum determinism: run the agent with `temperature=0` and a fixed model snapshot.

## Four layers of testing

| Layer | What it catches | Cost | Needs LLM |
|---|---|---|---|
| 1. **Preflight** (`preflight.sh` / `.ps1`) | Structural breakage: missing files, broken cross-refs, init-script syntax errors, personal-data leakage | ms | No |
| 2. **Init smoke test** (`test-init.sh` / `.ps1`) | `init-brain` regressions: missing renames, file-system errors, broken git reset | seconds | No |
| 3. **Cognitive memory tests** (`run.sh` / `.ps1` + fixtures) | Routing, operations, contracts. Real agent behavior. | minutes | Yes |
| 4. **Manual E2E** ([`MANUAL-CHECKLIST.md`](MANUAL-CHECKLIST.md)) | Onboarding flow, cross-tool persistence, maintainer-mode, full happy path | 30+ min | Yes |

**Run them in order before any release.** Layers 1 and 2 should pass cleanly every time — they're meant for CI. Layer 3 should pass with a real agent; flaky failures are usually LLM nondeterminism (re-run 2–3 times). Layer 4 is for human eyes.

## How to run

**Layer 1 — Preflight (instant):**
```bash
bash tests/preflight.sh        # POSIX
pwsh tests/preflight.ps1       # Windows
```

**Layer 2 — Init smoke test (seconds):**
```bash
bash tests/test-init.sh        # POSIX
pwsh tests/test-init.ps1       # Windows
```

**Layer 3 — Cognitive memory tests:**
```powershell
pwsh tests/run.ps1 -TestId 02-consolidation        # Windows
```

```bash
bash tests/run.sh 02-consolidation                 # POSIX
```

The runner:
1. Creates a sandbox at `<temp>/pivotex-test-<id>/`.
2. Copies fixture seed files into it.
3. Prints the action to perform — point your agent at the sandbox path and run it.
4. Waits for you to press Enter.
5. Executes `checks.ps1` / `checks.sh` against the sandbox.
6. Prints PASS or FAIL with details.

## Test catalog

See [`cognitive-memory-tests.md`](./cognitive-memory-tests.md) for all test specifications. Each test maps to a cognitive-psychology analog so you can reason about what's being measured.

Currently shipped with seed fixtures and assertions:
- `02-consolidation` — pattern detection (Hebbian-style)
- `03-source-citation` — source-attributed knowledge integration
- `04-contradiction` — handling conflicting claims

The other tests in `cognitive-memory-tests.md` are speced but unfixtured — contributions welcome.

## Adding a new test

Quick reference:

```
tests/fixtures/<id>/
├── seed/                    # files placed in the sandbox before the action
│   └── ...
├── checks.ps1              # Windows assertions (exit 0 = pass)
└── checks.sh               # Linux/macOS assertions (exit 0 = pass)
```

Add a description to `cognitive-memory-tests.md` and reference the cognitive analog.

For a step-by-step walkthrough with example assertions, see [`../docs/EXTENDING.md#adding-a-new-test`](../docs/EXTENDING.md#adding-a-new-test).

## What a failure means

- **Assertion: file expected, not found** → agent didn't follow the routing rule. Check `BRAIN.md` routing for that input type.
- **Assertion: source modified** → agent edited an immutable file. Check the boundaries section in `limbic/self.md`.
- **Assertion: content missing** → agent skipped a required write (e.g., citation). Check the relevant operation in `BRAIN.md`.
- **All assertions pass but behavior felt wrong** → the test caught file state, not LLM reasoning quality. Add a more specific assertion or a manual check in your stub instructions.

## Honest limitations

- We test **writes**, not reasoning. If the agent loaded the right files but reasoned poorly, no test will catch it.
- Tests assume the agent obeys `BRAIN.md`. If your stub doesn't load `BRAIN.md`, every test will fail in the same way.
- LLM nondeterminism means a test can pass once and fail another time on the same input. Run any failing test 2–3 times before declaring it a regression.
