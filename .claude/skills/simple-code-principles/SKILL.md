---
name: simple-code-principles
description: Guides code writing toward simplicity over perfection. Prefers YAGNI, KISS, DRY. Avoids backward-compat shims and fallback paths unless they add no cyclomatic complexity. Use when writing code, reviewing code, refactoring, or making architectural decisions.
---

# Simple Code Principles

## Core Rules

1. **Simplicity over pathological correctness** — Prefer straightforward solutions. Avoid over-engineering for hypothetical edge cases.
2. **YAGNI** (You Aren't Gonna Need It) — Don't add features, abstractions, or infrastructure until they're actually needed.
3. **KISS** (Keep It Simple, Stupid) — Choose the simplest approach that works.
4. **DRY** (Don't Repeat Yourself) — Eliminate duplication when it adds real value; don't abstract prematurely.
5. **No backward-compat shims or fallback paths** — Unless they come free (e.g., same code path, no extra branches). Avoid adding cyclomatic complexity for compatibility.

## When to Apply

- Writing new code
- Reviewing or refactoring existing code
- Making architectural or design decisions
- Adding abstractions, layers, or "future-proofing"

## Anti-Patterns to Avoid

| Avoid | Prefer |
|-------|--------|
| "We might need this later" abstractions | Implement when the need arises |
| Multiple code paths for version/legacy support | Single path; migrate or remove old |
| Defensive code for hypothetical failures | Handle real failure modes only |
| Over-generalized interfaces | Concrete, fit-for-purpose APIs |
| Premature DRY (extracting before 3rd use) | Duplicate twice; abstract on 3rd |

## Decision Heuristic

Before adding complexity, ask:
- Does this solve a **current** problem?
- Can we achieve the same with less code or fewer branches?
- Would removing this break anything that exists today?

If the answer to the last is "no" and the first two don't justify it, skip it.
