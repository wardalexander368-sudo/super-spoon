# REA setup log

## 2026-10-12: initial setup (Claude Code cloud session, Linux x64)

### Found
- REA ("Reverse Engineer Anything"), https://github.com/morluto/rea
  - npm package `rea-agents`, latest 6.4.0 (modified 2026-10-11), MIT license
  - Site: https://rea.tools
  - MCP Registry name: `io.github.morluto/rea`

### Installed
| Item | Detail |
| --- | --- |
| `rea-agents` | 6.4.0, exact pin in `package.json` devDependencies, plus `package-lock.json` |
| MCP server | `.mcp.json` → `npx -y rea-agents@6.4.0 mcp` (stdio), pre-approved via `.claude/settings.json` `enabledMcpjsonServers` |
| Skill | `.claude/skills/reverse-engineer-anything/` copied from `node_modules/rea-agents/skills/` (skill metadata version 37, tool_count 170), plus REA's MIT `LICENSE` |

Why project-level instead of `npx rea-agents setup`: setup writes to
`~/.claude.json` and `~/.claude/skills`. Those live outside the repo and would
not carry over to the Mac. The project files above produce the same
registration shape that setup writes (an exact-version `npx` runner).

### Verified (cloud container)
| Check | Result |
| --- | --- |
| Node | v22.22.0, npm 10.9.4 (meets ^22.19) |
| `npx rea --version` | 6.4.0 |
| MCP handshake (`initialize` + `tools/list` over stdio) | serverInfo `rea` 6.4.0, **170 tools** |
| `rea analyze-javascript-application samples/hello-electron --json` | exit 0 in ~3 s. Found IPC channel `notes:search`, `contextBridge.exposeInMainWorld`, preload and `searchNotes` call chain |
| `npm run smoke` | PASS |
| `rea doctor --json` | node ✅, host ✅ (Ubuntu 24.04). hopper ❌, ghidra ❌, ida ❌ (no engine installed). `registration:claude_code` ❌ and `skill:identity` ❌ are expected, because both live in the project rather than at user level |

### Not done / blocked
- **Native engine in the cloud container: decided to do this on the Mac.**
  Ghidra 12.1.4 couldn't be downloaded from GitHub (403). This is not the
  network policy: with full network access, other hosts load normally. Cloud
  sessions route all `github.com` traffic through a GitHub gateway that only
  allows git operations and repositories attached to the session, so release
  assets from other repos are refused whatever the network setting.
  - SourceForge's `ghidra.mirror` is reachable and has 12.1.4. It wasn't used
    because it's a third-party copy and the official checksum couldn't be
    checked from the session.
  - JDK 21 (`javac 21.0.12.1`) is present in the container.
- **Hopper.** Not installed. It's commercial (demo mode available) and is
  intended for the Mac. See `docs/MAC-PICKUP.md`.
- **The cloud container is ephemeral.** `node_modules/` is not committed, so
  run `npm ci` in each new session.

### Ready to test
- **Now (any machine with Node):** JavaScript/Electron apps and ASARs, .NET
  assemblies, archives (ZIP/APK/IPA/DMG inventory), Go build info, PE
  resources, HAR captures.
- **After installing Hopper or Ghidra on the Mac:** native macOS apps and
  binaries (pseudocode, assembly, xrefs, strings).
