#!/usr/bin/env bash
# End-to-end check that REA is installed and can analyze a JavaScript/Electron app.
# Needs only Node.js and `npm install`; no native engine (Hopper/Ghidra/IDA).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
target="$root/samples/hello-electron"
out="$root/evidence/hello-electron.json"

cd "$root"
echo "REA version: $(npx --no-install rea --version)"

# Progress lines go to stderr; the Evidence JSON goes to stdout.
npx --no-install rea analyze-javascript-application "$target" --json > "$out" 2>/dev/null

node - "$out" <<'EOF'
const fs = require('node:fs');
const evidence = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const text = JSON.stringify(evidence);
const expected = ['notes:search', 'exposeInMainWorld', 'searchNotes', 'src/preload.js'];
const missing = expected.filter((s) => !text.includes(s));
if (missing.length) {
  console.error(`FAIL: Evidence is missing ${missing.join(', ')}`);
  process.exit(1);
}
console.log(`PASS: evidence_id ${evidence.evidence_id}`);
console.log(`      found IPC channel, preload bridge and handler in ${process.argv[2]}`);
EOF
