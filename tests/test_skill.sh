#!/bin/sh
# Checks the plugin files. With --load, also asks a headless Claude Code
# session (plugin loaded from this repo) to list its skills.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fail() { echo "FAIL: $1"; exit 1; }

for f in "$ROOT"/.claude-plugin/*.json; do
  python3 -m json.tool "$f" >/dev/null || fail "$f is not valid JSON"
done
echo "ok: JSON files parse"

SKILL="$ROOT/skills/polish/SKILL.md"
head -1 "$SKILL" | grep -qx -- '---' || fail "SKILL.md has no frontmatter"
grep -q '^name: polish$' "$SKILL" || fail "SKILL.md name is not polish"
grep -q '^description: ' "$SKILL" || fail "SKILL.md has no description"
echo "ok: SKILL.md frontmatter"

if [ "$1" = "--load" ]; then
  out=$(claude -p --setting-sources project --plugin-dir "$ROOT" "List the names of the skills you have whose name contains 'polish', one per line, with their description. Nothing else.")
  echo "$out"
  echo "$out" | grep -qi "polish" || fail "skill polish not listed"
  echo "ok: skill loads"
fi
echo "all tests passed"
