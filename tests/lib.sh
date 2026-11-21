# Shared test helpers. Sourced by tests/test-*.sh.
export LC_ALL=C
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURES="$SCRIPT_DIR/fixtures"
MAX_MS="${MAX_MS:-3000}"

FAILURES=0
PASSES=0
TEST_ROOT="$(mktemp -d)"
export GIT_CEILING_DIRECTORIES="$(dirname "$TEST_ROOT")"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() { PASSES=$((PASSES + 1)); echo "  [PASS] $1"; }
fail() { FAILURES=$((FAILURES + 1)); echo "  [FAIL] $1"; }

# Path as Claude Code would send it: Windows form under Git Bash, POSIX otherwise.
native_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}

json_escape_path() { # native path -> JSON string body
  local p="$1"
  p="${p//\\/\\\\}"
  printf '%s' "$p"
}

now_ms() { local t; t="$(date +%s%N 2>/dev/null)"; printf '%s' "$((t / 1000000))"; }

# assert_eq <name> <expected> <actual>
assert_eq() {
  if [ "$2" = "$3" ]; then pass "$1: '$3'"; else fail "$1: expected '$2', got '$3'"; fi
}

summary() { # $1 = suite name
  echo
  echo "$1: $PASSES passed, $FAILURES failed"
  [ "$FAILURES" -eq 0 ]
}
