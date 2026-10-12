# Picking this up on the Mac

Everything REA needs at project level is committed. These steps get the Mac
to the same state as the cloud session, then add native analysis, which the
cloud session could not do.

## 1. Get the code

```bash
git clone https://github.com/wardalexander368-sudo/super-spoon.git
cd super-spoon
git checkout rea-setup   # or main, once this branch is merged
```

## 2. Node and the REA CLI

REA needs Node.js 22.x (>= 22.19), 24.x (>= 24.11) or 26+. Node 23 and 25 are
**not** supported.

```bash
node --version            # if missing or wrong: brew install node@24
npm ci                    # installs rea-agents 6.4.0 exactly as package-lock.json pins it
npm run smoke             # expect: PASS: evidence_id ev_...
```

## 3. Claude Code

```bash
claude
```

- The `rea` MCP server comes from `.mcp.json`, and `.claude/settings.json`
  pre-approves it. On first launch, accept the "trust this folder" prompt;
  until then `claude mcp list` shows `rea` as "Pending approval". After that,
  `/mcp` inside Claude Code should show `rea` as connected.
- The `reverse-engineer-anything` skill comes from `.claude/skills/`.
- You don't need `npx rea-agents setup` for Claude Code. It would add a
  second, user-level registration in `~/.claude.json` and a second skill copy
  in `~/.claude/skills`. Use setup only for the Hopper step below, and leave
  every agent unselected.

## 4. Native analysis engine (pick one)

Without an engine you still get JS/Electron, .NET, archives, Go metadata, PE
resources, plists and Mach-O signature/metadata. Pseudocode, assembly and
xrefs for compiled code need one of these:

### Option A: Hopper (simplest on macOS)

Hopper is commercial software. It has a free demo mode with vendor-defined
limits.

```bash
npx rea setup
```

- Deselect all agents. Answer **No** to the workflow/skill prompt, since this
  repo already ships it. Approve the Hopper install.
- REA downloads the official DMG, verifies its size and digest, and installs
  it to `~/Applications/Hopper Disassembler.app`. No Homebrew or admin rights
  are needed.
- Hopper then opens. Choose demo mode or enter a license.

If Hopper is already installed, REA detects it. Otherwise set
`HOPPER_LAUNCHER_PATH`.

### Option B: Ghidra (free)

REA accepts Ghidra **12.1.x** with a 64-bit **JDK 21+**:

```bash
brew install --cask temurin@21
# Download ghidra_12.1.4_PUBLIC_*.zip from
# https://github.com/NationalSecurityAgency/ghidra/releases and unzip it, e.g. ~/tools/
```

The MCP server inherits its environment from Claude Code, so export these in
`~/.zshrc` and then open a new terminal:

```bash
export GHIDRA_INSTALL_DIR="$HOME/tools/ghidra_12.1.4_PUBLIC"
export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
```

Run `npm run doctor` and check the `ghidra` entry. If it reports
`native_decompiler` missing on an Intel Mac, build it with Xcode Command Line
Tools (REA documents this recipe for macOS x64 only):

```bash
cd "$GHIDRA_INSTALL_DIR/Ghidra/Features/Decompiler/src/decompile/cpp"
make ghidra_opt
d="$GHIDRA_INSTALL_DIR/Ghidra/Features/Decompiler/os/mac_x86_64"
mkdir -p "$d" && install -m 755 ghidra_opt "$d/decompile"
```

Large binaries may need `REA_GHIDRA_STARTUP_TIMEOUT_MS` (default 330000).

## 5. Check readiness

```bash
npm run doctor
```

On a Claude Code-only project setup these checks are expected to fail and are
fine to ignore:

- `registration:claude_code`: the registration is project-level, not in
  `~/.claude.json`.
- `skill:identity`: the skill is project-level, not in `~/.claude/skills`.
- Whichever engines you did not install.

## 6. First real test

Copy or point at the app (absolute paths). For example:

```text
Use REA to understand how <feature> works in /Applications/<App>.app.
Show the evidence, list the unknowns, and write it up in investigations/.
```

Good first targets:

- **An Electron app** (Slack, Discord, VS Code, Notion): static analysis
  needs no engine. Point REA at `<App>.app/Contents/Resources/app.asar`.
- **A native macOS app** (Notes, Preview, your own builds): needs Hopper or
  Ghidra.

## Keep the Mac copy updated (hourly pull)

From the repo folder, run once:

```bash
bash scripts/install-mac-autopull.sh
```

This installs a launchd agent (`com.super-spoon.autopull`) that runs
`scripts/autopull.sh` every hour and at login:

- It only fast-forwards (`git pull --ff-only`), so it never merges, rebases
  or discards anything.
- It skips that hour if you have uncommitted changes to tracked files.
  Ignored folders like `targets/` and `evidence/` don't count.
- It logs an error and changes nothing if your local commits and GitHub's
  have diverged. Run `git pull` yourself to sort that out.
- It runs `npm ci` when `package.json` or `package-lock.json` changed,
  for example after a REA upgrade.

Log: `~/Library/Logs/super-spoon-autopull.log`. Check it with:

```bash
tail ~/Library/Logs/super-spoon-autopull.log
```

To remove the agent: `bash scripts/install-mac-autopull.sh --uninstall`.
If you move the repo folder, run the installer again from the new location.

Troubleshooting:

- **`Operation not permitted` in the log:** the repo is under Desktop,
  Documents or Downloads, which macOS protects from background jobs. Move it
  somewhere like `~/Rev_Eng` (avoid iCloud-synced folders for git repos in
  any case) and reinstall. Alternatively, give `/bin/bash` Full Disk Access
  in System Settings → Privacy & Security.
- **`could not read Username` in the log:** git has no stored GitHub login
  for background use. Run `gh auth login` and then `gh auth setup-git`.

## Upgrading REA

Keep the version identical in all three places:

```bash
npm view rea-agents dist-tags.latest          # e.g. 6.5.0
npm install --save-dev --save-exact rea-agents@6.5.0
# edit .mcp.json: "rea-agents@6.5.0"
rm -rf .claude/skills/reverse-engineer-anything
cp -r node_modules/rea-agents/skills/reverse-engineer-anything .claude/skills/
cp node_modules/rea-agents/LICENSE .claude/skills/reverse-engineer-anything/
npm run smoke
```

Then restart Claude Code.
