#!/usr/bin/env bash
# Test runner for claude-update. Pure bash + diff/grep, no external deps.
#
# Each case sets up a stub `claude` (see stub/claude) and a fixture CHANGELOG,
# runs the script with --no-pager, then asserts on stdout+stderr and exit status.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$ROOT/test"
FIXTURE="$TEST_DIR/fixtures/changelog.md"
SCRIPT="$ROOT/claude-update"

if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  GREEN=""; RED=""; DIM=""; RESET=""
fi

PASS=0
FAIL=0
FAILED_NAMES=()

# run_script <pre> <post> <upd_exit> [extra args...]
# Populates globals: OUTPUT, STATUS
run_script() {
  local pre="$1" post="$2" upd_exit="$3"
  shift 3

  local tmp; tmp=$(mktemp -d -t claude-update-test.XXXXXX)
  local versions="$tmp/versions" state="$tmp/state"
  printf '%s\n%s\n%s\n' "$pre" "$post" "$upd_exit" > "$versions"

  set +e
  OUTPUT=$(
    PATH="$TEST_DIR/stub:$PATH" \
    CLAUDE_UPDATE_CHANGELOG_URL="file://$FIXTURE" \
    STUB_STATE_FILE="$state" \
    STUB_VERSIONS_FILE="$versions" \
    "$SCRIPT" --no-pager "$@" 2>&1
  )
  STATUS=$?
  set -e

  rm -rf "$tmp"
}

assert() {
  local name="$1" cond_desc="$2"
  if eval "$3"; then
    printf '  %s✓%s %s — %s\n' "$GREEN" "$RESET" "$name" "$cond_desc"
  else
    printf '  %s✗%s %s — %s\n' "$RED" "$RESET" "$name" "$cond_desc"
    printf '%s' "$OUTPUT" | sed 's/^/      /'
    printf '\n      (status=%s)\n' "$STATUS"
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name: $cond_desc")
    return 1
  fi
}

case_start() {
  printf '\n%s%s%s\n' "$DIM" "▸ $1" "$RESET"
}

case_end() {
  PASS=$((PASS + 1))
}

# ---------------------------------------------------------------------------
# Case 1: happy path — normal upgrade across several versions
# ---------------------------------------------------------------------------
case_start "happy path: 2.1.122 → 2.1.129"
run_script "2.1.122" "2.1.129" "0"
assert "happy" "exits 0"             '[[ "$STATUS" == "0" ]]' && \
assert "happy" "shows old version"   'grep -q "current version: 2.1.122" <<< "$OUTPUT"' && \
assert "happy" "shows new version"   'grep -q "new version:.*2.1.129" <<< "$OUTPUT"' && \
assert "happy" "includes 2.1.129"    'grep -q "## 2.1.129" <<< "$OUTPUT"' && \
assert "happy" "includes 2.1.128"    'grep -q "## 2.1.128" <<< "$OUTPUT"' && \
assert "happy" "includes 2.1.126"    'grep -q "## 2.1.126" <<< "$OUTPUT"' && \
assert "happy" "includes 2.1.123"    'grep -q "## 2.1.123" <<< "$OUTPUT"' && \
assert "happy" "excludes 2.1.122"    '! grep -q "## 2.1.122" <<< "$OUTPUT"' && \
assert "happy" "excludes 2.1.120"    '! grep -q "## 2.1.120" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 2: already on latest
# ---------------------------------------------------------------------------
case_start "already on latest: 2.1.129 → 2.1.129"
run_script "2.1.129" "2.1.129" "0"
assert "latest" "exits 0"            '[[ "$STATUS" == "0" ]]' && \
assert "latest" "shows already msg"  'grep -q "already on latest" <<< "$OUTPUT"' && \
assert "latest" "shows 2.1.129"      'grep -q "## 2.1.129" <<< "$OUTPUT"' && \
assert "latest" "no 2.1.128"         '! grep -q "## 2.1.128" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 3: skipped versions — old version not present in CHANGELOG
# ---------------------------------------------------------------------------
case_start "skip-versions: 2.1.125 (not in CHANGELOG) → 2.1.129"
run_script "2.1.125" "2.1.129" "0"
assert "skip" "exits 0"              '[[ "$STATUS" == "0" ]]' && \
assert "skip" "includes 2.1.129"     'grep -q "## 2.1.129" <<< "$OUTPUT"' && \
assert "skip" "includes 2.1.128"     'grep -q "## 2.1.128" <<< "$OUTPUT"' && \
assert "skip" "includes 2.1.126"     'grep -q "## 2.1.126" <<< "$OUTPUT"' && \
assert "skip" "excludes 2.1.123"     '! grep -q "## 2.1.123" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 4: first install — old version is empty
# ---------------------------------------------------------------------------
case_start "first install: '' → 2.1.129"
run_script "" "2.1.129" "0"
assert "first" "exits 0"             '[[ "$STATUS" == "0" ]]' && \
assert "first" "shows not installed" 'grep -q "not installed" <<< "$OUTPUT"' && \
assert "first" "first-install hint"  'grep -q "first install" <<< "$OUTPUT"' && \
assert "first" "shows 2.1.129"       'grep -q "## 2.1.129" <<< "$OUTPUT"' && \
assert "first" "no 2.1.128"          '! grep -q "## 2.1.128" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 5: prerelease in CHANGELOG (2.1.130-beta1 above 2.1.129)
# ---------------------------------------------------------------------------
case_start "prerelease in CHANGELOG: 2.1.128 → 2.1.129 (130-beta1 must be skipped)"
run_script "2.1.128" "2.1.129" "0"
assert "prerel" "exits 0"            '[[ "$STATUS" == "0" ]]' && \
assert "prerel" "stderr prerel hint" 'grep -q "prerelease tags" <<< "$OUTPUT"' && \
assert "prerel" "includes 2.1.129"   'grep -q "## 2.1.129" <<< "$OUTPUT"' && \
assert "prerel" "no 2.1.130-beta1"   '! grep -q "## 2.1.130-beta1" <<< "$OUTPUT"' && \
assert "prerel" "no 2.1.128"         '! grep -q "## 2.1.128" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 6: claude update fails
# ---------------------------------------------------------------------------
case_start "update fails (exit 7)"
run_script "2.1.122" "2.1.129" "7"
assert "fail" "exits 1"              '[[ "$STATUS" == "1" ]]' && \
assert "fail" "shows failure msg"    'grep -q "claude update failed" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 7: --help (no claude/curl invocation)
# ---------------------------------------------------------------------------
case_start "--help prints usage and exits 0"
set +e
HELP_OUT=$("$SCRIPT" --help 2>&1)
HELP_STATUS=$?
set -e
OUTPUT="$HELP_OUT"; STATUS="$HELP_STATUS"
assert "help" "exits 0"              '[[ "$STATUS" == "0" ]]' && \
assert "help" "contains Usage:"      'grep -q "Usage:" <<< "$OUTPUT"' && \
assert "help" "mentions --no-pager"  'grep -q -- "--no-pager" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Case 8: unknown argument exits 2
# ---------------------------------------------------------------------------
case_start "unknown argument exits 2"
set +e
BAD_OUT=$("$SCRIPT" --not-a-flag 2>&1)
BAD_STATUS=$?
set -e
OUTPUT="$BAD_OUT"; STATUS="$BAD_STATUS"
assert "bad" "exits 2"               '[[ "$STATUS" == "2" ]]' && \
assert "bad" "mentions unknown"      'grep -q "unknown argument" <<< "$OUTPUT"' && \
assert "bad" "prints usage"          'grep -q "Usage:" <<< "$OUTPUT"' && \
case_end

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
printf '\n────────────────────────────\n'
if [[ "$FAIL" == "0" ]]; then
  printf '%s%s/%s cases passed%s\n' "$GREEN" "$PASS" "$TOTAL" "$RESET"
  exit 0
else
  printf '%s%s passed, %s failed%s\n' "$RED" "$PASS" "$FAIL" "$RESET"
  printf 'failed assertions:\n'
  for name in "${FAILED_NAMES[@]}"; do printf '  - %s\n' "$name"; done
  exit 1
fi
