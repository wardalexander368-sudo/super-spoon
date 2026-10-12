# super-spoon

Reverse engineering workspace built on **REA (Reverse Engineer Anything)**,
https://github.com/morluto/rea. Use this repo to work out how a feature in a
shipped app works (no source code needed) and, when asked, build a similar
feature.

## How REA is wired in

- `.mcp.json` registers the `rea` MCP server (`npx -y rea-agents@6.4.0 mcp`).
  `.claude/settings.json` pre-approves it. Tools appear as `mcp__rea__*`
  (170 tools in 6.4.0).
- `.claude/skills/reverse-engineer-anything/` is the workflow skill bundled
  with REA 6.4.0. Follow it for routing, summary-first work and evidence rules.
- `package.json` pins `rea-agents` 6.4.0 so `npx rea ...` works offline after
  `npm install`. Keep the version identical in `package.json`, `.mcp.json` and
  the skill when upgrading (see `docs/MAC-PICKUP.md#upgrading-rea`).

## Folders

- `targets/`: copies of apps, binaries, ASARs and APKs under investigation.
  Git-ignored, because they can contain third-party code.
- `evidence/`: Evidence JSON written by REA. Git-ignored.
- `samples/hello-electron/`: tiny known-good target used by `npm run smoke`.
  Don't use it as the target of a real investigation.
- `investigations/`: one Markdown write-up per investigation (findings,
  Evidence IDs, unknowns). These are committed.
- `docs/`: setup log and Mac pickup instructions.

## Working rules

- If the user says "my app" without naming it, ask which app. Never choose a
  sample on their behalf.
- Pass absolute paths to REA tools.
- Separate observations, inferences and unknowns. Cite Evidence IDs and keep
  REA's stated limitations.
- Static analysis needs nothing but Node: JS/Electron, .NET, archives, Go, PE
  resources. Native pseudocode needs Hopper, Ghidra or IDA on the host. Check
  with `npm run doctor` only when a native tool reports a missing provider.
- Record each investigation in `investigations/<date>-<app>-<feature>.md`.

## Commands

```bash
npm install          # installs the pinned REA CLI
npm run smoke        # end-to-end check on samples/hello-electron
npm run doctor       # REA readiness report (engines, registrations)
npx rea --help       # full CLI
```
