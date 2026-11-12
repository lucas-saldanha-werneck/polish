#!/bin/sh
# Checks the plugin files. With --load, also starts a headless Claude Code
# session with the plugin loaded from this repo and checks that it registers
# the skill polish:polish.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fail() { echo "FAIL: $1"; exit 1; }

# Reads `claude -p --output-format stream-json --verbose` output on stdin.
# Passes only if the session's init event lists the skill polish:polish.
# The model's own words are never trusted.
skill_loaded() {
  python3 -c '
import json, sys
for line in sys.stdin:
    try:
        e = json.loads(line)
    except ValueError:
        continue
    if isinstance(e, dict) and e.get("type") == "system" and e.get("subtype") == "init":
        sys.exit(0 if "polish:polish" in (e.get("skills") or []) else 1)
sys.exit(1)
'
}

for f in "$ROOT"/.claude-plugin/*.json; do
  python3 -m json.tool "$f" >/dev/null || fail "$f is not valid JSON"
done
echo "ok: JSON files parse"

SKILL="$ROOT/skills/polish/SKILL.md"
head -1 "$SKILL" | grep -qx -- '---' || fail "SKILL.md has no frontmatter"
grep -q '^name: polish$' "$SKILL" || fail "SKILL.md name is not polish"
grep -q '^description: ' "$SKILL" || fail "SKILL.md has no description"
echo "ok: SKILL.md frontmatter"

# Undoing a step must not leave later steps that depend on it, and the end
# needs one full test run against the baseline.
grep -q 'depends on:' "$SKILL" || fail "SKILL.md plan steps don't list what they depend on"
grep -q 'skip every later step that depends on it' "$SKILL" || fail "SKILL.md rollback ignores dependent steps"
grep -q 'run the full test suite once more' "$SKILL" || fail "SKILL.md has no final full test run"
echo "ok: SKILL.md rollback rules"

# Undoing a step must never take the user's uncommitted work with it.
grep -q 'git status' "$SKILL" || fail "SKILL.md does not check for uncommitted work before changing files"
grep -q 'never `git checkout -- .`' "$SKILL" || fail "SKILL.md does not forbid undoing with a blanket checkout or reset"
echo "ok: SKILL.md keeps uncommitted work"

# Nothing is written into the target before the user picks.
grep -q 'polish-report.md` in the target' "$SKILL" && fail "SKILL.md writes the report into the target before the user picks"
grep -q 'never in the target' "$SKILL" || fail "SKILL.md does not keep the report out of the target"
echo "ok: SKILL.md report stays out of the target"

# The load check must fail when the skill is missing, whatever the model says.
# The init event comes before any model call, so it works without a login
# (the session then fails, which is fine: only the init event is read).
echo 'No skills containing polish are available.' | skill_loaded && fail "load check accepts a plain-text answer"
echo '{"type":"system","subtype":"init","skills":["other:polish-like"]}' | skill_loaded && fail "load check accepts a missing skill"
echo '{"type":"system","subtype":"init","skills":["polish:polish"]}' | skill_loaded || fail "load check rejects a loaded skill"
echo "ok: load check"

if [ "$1" = "--load" ]; then
  out=$(claude -p --setting-sources project --plugin-dir "$ROOT" --output-format stream-json --verbose \
    --max-turns 1 "Reply with the word ok." 2>/dev/null || true)
  echo "$out" | skill_loaded || fail "skill polish:polish not registered"
  echo "ok: skill loads (polish:polish)"
fi
echo "all tests passed"
