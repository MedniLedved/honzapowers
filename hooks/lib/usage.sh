# Transcript usage parser shared by hooks/user-prompt-submit and
# scripts/session-metrics. Sourced, not executed. No jq.
#
# The transcript JSONL (undocumented format) records per response:
#   "usage":{"input_tokens":N,"cache_creation_input_tokens":N,"cache_read_input_tokens":N,...}
# Their sum is the context size at that response. Several lines of one response
# repeat the same usage; zero sums (API errors, synthetic messages) are skipped.

USAGE_TAIL_BYTES="${USAGE_TAIL_BYTES:-2000000}"

usage_input_sum() { # $1 = usage object text; sets USAGE_SUM (no subshells: forks are slow on Windows)
  local k re
  USAGE_SUM=0
  for k in input_tokens cache_creation_input_tokens cache_read_input_tokens; do
    re="\"$k\":[[:space:]]*([0-9]+)"
    [[ $1 =~ $re ]] && USAGE_SUM=$((USAGE_SUM + BASH_REMATCH[1]))
  done
}

last_context_tokens() { # $1 = transcript path; prints tokens or returns 1
  local f="$1" u last=""
  [ -f "$f" ] || return 1
  # Each usage object up to its first '}' holds the three input keys
  # (nested objects come after them). The newest non-zero record wins.
  while IFS= read -r u; do
    usage_input_sum "$u"
    [ "$USAGE_SUM" -gt 0 ] && last="$USAGE_SUM"
  done < <(tail -c "$USAGE_TAIL_BYTES" "$f" 2>/dev/null | grep '"type":"assistant"' \
    | grep -o '"usage":{[^}]*' | tail -n 20)
  if [ -z "$last" ]; then
    # Nothing in the tail (one huge line, e.g. a large tool result): scan the
    # whole file once before the caller falls back to a size estimate.
    while IFS= read -r u; do
      usage_input_sum "$u"
      [ "$USAGE_SUM" -gt 0 ] && last="$USAGE_SUM"
    done < <(grep '"type":"assistant"' "$f" 2>/dev/null | grep -o '"usage":{[^}]*' | tail -n 20)
  fi
  [ -n "$last" ] || return 1
  printf '%s' "$last"
}

file_size_tokens() { # $1 = transcript path; rough fallback: bytes / 6
  # Measured on 2.1.321 transcripts: ~5-6 bytes of JSONL per context token.
  local n
  n="$(wc -c <"$1" 2>/dev/null | tr -d ' ')"
  case "$n" in '' | *[!0-9]*) return 1 ;; esac
  printf '%s' "$((n / 6))"
}
