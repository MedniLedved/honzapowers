#!/usr/bin/env bash
# Unit tests for hooks/lib/*.sh. Run: bash tests/test-lib.sh
set -uo pipefail

. "$(dirname "$0")/lib.sh"
. "$REPO_ROOT/hooks/lib/common.sh"
. "$REPO_ROOT/hooks/lib/usage.sh"

echo "to_bash_path"
assert_eq backslash /c/Users/x/proj "$(to_bash_path 'C:\Users\x\proj')"
assert_eq slash /d/work/a "$(to_bash_path 'D:/work/a')"
assert_eq posix /home/u/p "$(to_bash_path /home/u/p)"
assert_eq empty "" "$(to_bash_path '')"

echo "json helpers"
input='{"a":"x\"y\\z","n":12.5,"t":true,"f":false}'
assert_eq json_string 'x"y\z' "$(json_string a)"
assert_eq json_number 12.5 "$(json_number n)"
json_true t && pass "json_true t" || fail "json_true t"
json_true f && fail "json_true f" || pass "json_true f is false"
assert_eq missing "" "$(json_string nope)"

echo "sanitize and escape_for_json"
assert_eq sanitize "abrm.md" "$(sanitize 'a b;$(rm).md')"
assert_eq escape 'a\"b\\c\nd' "$(escape_for_json $'a"b\\c\nd')"

echo "usage parser"
usage_input_sum '"usage":{"input_tokens":3,"cache_creation_input_tokens":20,"cache_read_input_tokens":100,"output_tokens":9'
assert_eq usage_sum 123 "$USAGE_SUM"
assert_eq last_valid 120502 "$(last_context_tokens "$FIXTURES/transcripts/valid.jsonl")"
assert_eq last_reordered 101000 "$(last_context_tokens "$FIXTURES/transcripts/reordered.jsonl")"
last_context_tokens "$FIXTURES/transcripts/no-usage.jsonl" >/dev/null && fail "no-usage returns 1" || pass "no-usage returns 1"
last_context_tokens "$TEST_ROOT/none.jsonl" >/dev/null && fail "missing returns 1" || pass "missing returns 1"
assert_eq file_size "$(($(wc -c <"$FIXTURES/transcripts/valid.jsonl") / 6))" "$(file_size_tokens "$FIXTURES/transcripts/valid.jsonl")"

summary lib
