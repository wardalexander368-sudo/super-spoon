# Investigations

Use one file per investigation: `YYYY-MM-DD-<app>-<feature>.md`. Raw Evidence
JSON stays in `evidence/` (git-ignored). Record its Evidence IDs here so the
findings can be traced.

## Template

```markdown
# <App> — <feature>

- Date:
- Target: <absolute path>, version, SHA-256 (from REA Evidence)
- REA version / engine: 6.4.0 / <none | Hopper | Ghidra | IDA>

## Questions
1. ...

## Findings
| # | Finding | Type (observed / inferred) | Evidence ID |
| - | ------- | -------------------------- | ----------- |

## Unknowns and limits

## Reimplementation notes (if building a version of it)

## Status per question
answered / partial / unresolved
```
