# Shared helpers for honzapowers hooks. Sourced, not executed.
# The JSON helpers read the global $input (the hook's stdin) with bash regex
# only: no jq, no subprocesses.

MAX_PATH_CHARS="${MAX_PATH_CHARS:-120}" # per printed path

json_string() { # $1 = key; prints the unescaped string value or nothing
  local re="\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\""
  [[ $input =~ $re ]] || return 0
  local v="${BASH_REMATCH[1]}"
  v="${v//\\\\/$'\001'}"
  v="${v//\\\"/\"}"
  v="${v//\\\//\/}"
  v="${v//$'\001'/\\}"
  printf '%s' "$v"
}

json_number() { # $1 = key; prints the number or nothing
  local re="\"$1\"[[:space:]]*:[[:space:]]*([0-9]+(\.[0-9]+)?)"
  [[ $input =~ $re ]] && printf '%s' "${BASH_REMATCH[1]}"
}

json_true() { # $1 = key; succeeds when the value is true
  local re="\"$1\"[[:space:]]*:[[:space:]]*true"
  [[ $input =~ $re ]]
}

to_bash_path() { # Windows path (C:\x\y or C:/x/y) -> Git Bash form /c/x/y; others unchanged
  local p="$1"
  if [[ $p =~ ^([A-Za-z]):[\\/](.*)$ ]]; then
    local drive="${BASH_REMATCH[1],,}" rest="${BASH_REMATCH[2]//\\//}"
    p="/$drive/$rest"
  fi
  printf '%s' "$p"
}

sanitize() { # untrusted path or name -> safe, bounded token
  local p="${1//[^A-Za-z0-9._\/-]/}"
  printf '%s' "${p:0:$MAX_PATH_CHARS}"
}

escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  s="${s//[$'\001'-$'\037']/}"
  printf '%s' "$s"
}
