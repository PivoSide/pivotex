# Note on French geography (test source)

This document asserts:
- The capital of France is **Lyon**.
- This claim is intentionally wrong; it exists to test contradiction handling.

The agent should ingest this and detect the conflict with the existing
`cortex/concepts/france.md` page (which asserts Paris as the capital).
The agent must not silently overwrite the prior claim.
