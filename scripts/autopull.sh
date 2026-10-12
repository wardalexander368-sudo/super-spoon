#!/bin/bash
# Fast-forwards this clone to its upstream branch. Never merges, rebases or
# discards anything: it skips when there is uncommitted work and logs an error
# when the branch has diverged. Run hourly by launchd (see install-mac-autopull.sh).
set -u

# launchd starts jobs with a minimal PATH; add Homebrew's for git/node/npm.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export GIT_TERMINAL_PROMPT=0

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo" || { log "error: cannot enter $repo"; exit 1; }

branch="$(git symbolic-ref --short -q HEAD)" || { log "skip: detached HEAD"; exit 0; }

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  log "skip: uncommitted changes on $branch"
  exit 0
fi

before="$(git rev-parse HEAD)"
if ! out="$(git pull --ff-only --quiet 2>&1)"; then
  log "error: pull failed on $branch: ${out##*$'\n'}"
  exit 1
fi
after="$(git rev-parse HEAD)"

if [ "$before" = "$after" ]; then
  log "up to date: $branch @ ${after:0:7}"
  exit 0
fi
log "updated $branch: ${before:0:7} -> ${after:0:7}"

# Keep the pinned REA CLI in node_modules in step with package-lock.json.
if ! git diff --quiet "$before" "$after" -- package.json package-lock.json; then
  if out="$(npm install --no-audit --no-fund 2>&1)"; then
    log "npm install: done"
  else
    log "error: npm install failed: ${out##*$'\n'}"
    exit 1
  fi
fi
