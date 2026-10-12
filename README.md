# super-spoon

A reverse engineering workspace built on
[REA: Reverse Engineer Anything](https://github.com/morluto/rea) (`rea-agents`
6.4.0, MIT). Open this folder in Claude Code and ask things like:

> Understand how search works in the Notes app, show me the evidence, and build
> a similar feature for my project.

## Quick start

```bash
npm install       # Node 22.19+, 24.11+ or 26+
npm run smoke     # should print PASS
claude            # REA's MCP server and skill load from this repo
```

On a Mac, also install a native analysis engine (Hopper or Ghidra) to get
pseudocode from compiled apps. See [docs/MAC-PICKUP.md](docs/MAC-PICKUP.md).

## What's here

| Path | Purpose |
| --- | --- |
| `.mcp.json` | Registers the `rea` MCP server for Claude Code (project scope) |
| `.claude/settings.json` | Pre-approves that server |
| `.claude/skills/reverse-engineer-anything/` | REA's workflow skill, matching 6.4.0 |
| `CLAUDE.md` | Project instructions for Claude |
| `samples/hello-electron/` | Known-good target for the smoke test |
| `scripts/smoke-test.sh` | End-to-end check (`npm run smoke`) |
| `scripts/install-mac-autopull.sh` | Mac: hourly safe `git pull` via launchd (`--uninstall` to remove) |
| `targets/` | Put apps under investigation here (git-ignored) |
| `evidence/` | REA Evidence output (git-ignored) |
| `investigations/` | Committed write-ups of each investigation |
| `docs/SETUP-LOG.md` | What was installed and verified, and when |
| `docs/MAC-PICKUP.md` | Steps to continue on the Mac |
