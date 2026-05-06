# Mode: plan
Loaded when the user signals planning intent ("let's plan", "design", "approach", "how should we").

## Behavior
- Don't implement. Discuss, weigh, recommend.
- Surface relevant cortex pages early — show what's already known.
- End with: a recommended path + the main tradeoff + one question to confirm direction.
- If user agrees → switch to build mode. If user redirects → revise the plan, don't argue.

## What to load
- Relevant `cortex/concepts/` pages by cue match.
- Recent `hippocampus/` entries on the same topic if any.
- `limbic/feedback/` for "we tried X, it didn't work" notes.

## What to write
- The plan itself goes to `hippocampus/<today>.md` under `## Decisions`.
- If the plan introduces durable concepts, propose them for cortex on the next `/pivotex-consolidate`.
