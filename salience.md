# Salience map
Cues → memories. Drives selective context loading.
`/pivotex-consolidate` tunes weights based on what fires + gets used. Hand-editable.

Format:
```
## Cue: "<term1>" | "<term2>" | regex pattern
→ <path> (weight: 0.0–1.0, last: YYYY-MM-DD)
```

---

## Cue: "memory" | "brain" | "cortex" | "agent memory"
→ BRAIN.md (weight: 1.0)
→ cortex/concepts/pivotex-design.md (weight: 0.9)

## Cue: "consolidate" | "sleep pass" | "weekly review"
→ BRAIN.md#consolidate (weight: 0.8)

## Cue: "ingest" | "new document" | "drop a source" | "I have a paper"
→ BRAIN.md#ingest (weight: 0.8)

## Cue: "dream" | "speculation" | "what if" | "any patterns"
→ dreams/ (weight: 0.6)
→ BRAIN.md#dream (weight: 0.7)

## Cue: corrections | "no" | "stop doing" | "don't"
→ limbic/feedback/ (weight: 1.0, always)

## Cue: "I prefer" | "I like" | "I'm a..." | identity statements
→ limbic/user.md (weight: 1.0)

## Cue: "let's plan" | "design" | "approach" | "how should we"
→ cerebellum/modes/plan.md (weight: 0.9)

## Cue: "summarize" | "what did we" | "where did we leave"
→ hippocampus/_last7days.md (weight: 0.9)
→ hippocampus/<today>.md (weight: 1.0)
