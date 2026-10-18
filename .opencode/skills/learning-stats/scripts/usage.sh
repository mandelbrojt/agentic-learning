#!/usr/bin/env bash
# Usage tracking and the central statistics log for agentic-learning skills.
#
# Usage:
#   usage.sh start               Save a usage baseline for the current OpenCode session.
#   usage.sh report <skill>      Print the usage since the baseline as JSON, then drop the baseline.
#   usage.sh log '<event-json>'  Append one event to the central log (JSON can also come from stdin).
#   usage.sh path                Print the central log path.
#
# Reads the session from $OPENCODE_SESSION_ID and the data through `opencode api`.
# Needs jq. Data lives in $AGENTIC_LEARNING_DATA_DIR, or by default in
# ${XDG_DATA_HOME:-~/.local/share}/agentic-learning:
#   events.jsonl                 central log, one JSON event per line, append-only
#   baselines/<sessionID>.json   temporary baselines between `start` and `report`
# USAGE_PAGE_SIZE sets how many messages are read per API request (default 100).
#
# Usage tracking must never block a skill: `start` and `report` always exit 0
# and print {"available": false, "reason": "..."} when usage can't be read.
# `log` exits 1 when the event is invalid or can't be written.

DATA_DIR="${AGENTIC_LEARNING_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/agentic-learning}"
LOG_FILE="$DATA_DIR/events.jsonl"
BASELINE_DIR="$DATA_DIR/baselines"
SID="${OPENCODE_SESSION_ID:-}"

have() { command -v "$1" >/dev/null 2>&1; }
now_ms() { echo $(( $(date +%s) * 1000 )); }
now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

unavailable() {
  local reason="${1//\"/\'}"
  printf '{"available":false,"reason":"%s"}\n' "$reason"
  exit 0
}

# Large responses can be cut off when `opencode api` writes to a pipe, so go through a file.
api() {
  local tmp status
  tmp="$(mktemp)" || return 1
  opencode api get "$1" >"$tmp" 2>/dev/null
  status=$?
  [ $status -eq 0 ] && cat "$tmp"
  rm -f "$tmp"
  return $status
}

require_usage_sources() {
  have jq || unavailable "jq is not installed"
  have opencode || unavailable "opencode CLI not found"
  [ -n "$SID" ] || unavailable "OPENCODE_SESSION_ID is not set (not running inside OpenCode?)"
}

session_info() {
  local out
  out="$(api "/api/session/$1")" || return 1
  printf '%s' "$out" | jq -e '.data | select(.id)' 2>/dev/null
}

# Sum cost and tokens of all descendant sessions created at or after $2 (ms).
descendants() {
  local parent="$1" since="$2" page children
  page="$(api "/api/session?parentID=$parent&limit=200")" || { echo '[]'; return; }
  children="$(printf '%s' "$page" | jq -c --argjson since "$since" \
    '[.data[]? | select(.time.created >= $since)]' 2>/dev/null)" || children='[]'
  local all="$children" id
  for id in $(printf '%s' "$children" | jq -r '.[].id'); do
    all="$(jq -c -n --argjson a "$all" --argjson b "$(descendants "$id" "$since")" '$a + $b')"
  done
  printf '%s' "$all"
}

# Largest context (input + cache read + cache write) of a single assistant step since $1 (ms).
peak_context() {
  local since="$1" size="${USAGE_PAGE_SIZE:-100}" peak=0 page result
  local query="type=assistant&order=desc&limit=$size"
  while :; do
    page="$(api "/api/session/$SID/message?$query")" || break
    result="$(printf '%s' "$page" | jq -c --argjson since "$since" --argjson peak "$peak" '
      ([.data[]? | select(.tokens != null and (.time.completed // .time.created) >= $since)
        | .tokens.input + .tokens.cache.read + .tokens.cache.write] + [$peak] | max) as $p
      | { peak: $p,
          done: ((.data | length) == 0 or ([.data[]? | .time.completed // .time.created] | min) < $since),
          next: .cursor.next }')" || break
    peak="$(printf '%s' "$result" | jq '.peak')"
    [ "$(printf '%s' "$result" | jq '.done')" = "true" ] && break
    local next; next="$(printf '%s' "$result" | jq -r '.next // empty')"
    [ -n "$next" ] || break
    query="type=assistant&limit=$size&cursor=$next"
  done
  echo "$peak"
}

cmd_start() {
  require_usage_sources
  local s
  s="$(session_info "$SID")" || unavailable "could not read session $SID from the OpenCode API"
  mkdir -p "$BASELINE_DIR" || unavailable "could not create $BASELINE_DIR"
  printf '%s' "$s" | jq -c --argjson t "$(now_ms)" \
    '{sessionID: .id, time: $t, cost: (.cost // 0), tokens: .tokens}' \
    >"$BASELINE_DIR/$SID.json" || unavailable "could not write the baseline"
  jq -c '{available: true, baseline: .}' "$BASELINE_DIR/$SID.json"
}

cmd_report() {
  local skill="${1:-}"
  [ -n "$skill" ] || { echo "Usage: usage.sh report <skill>" >&2; exit 2; }
  require_usage_sources

  local s baseline_file="$BASELINE_DIR/$SID.json" baseline baseline_missing=false
  s="$(session_info "$SID")" || unavailable "could not read session $SID from the OpenCode API"
  if [ -r "$baseline_file" ]; then
    baseline="$(cat "$baseline_file")"
  else
    baseline_missing=true
    baseline='{"time":0,"cost":0,"tokens":{"input":0,"output":0,"reasoning":0,"cache":{"read":0,"write":0}}}'
  fi
  local since; since="$(printf '%s' "$baseline" | jq '.time')"

  local subs peak models limit
  subs="$(descendants "$SID" "$since")"
  peak="$(peak_context "$since")"
  models="$(api /api/model)" || models='{"data":[]}'
  limit="$(printf '%s' "$models" | jq --argjson m "$(printf '%s' "$s" | jq -c '.model')" \
    '[.data[]? | select(.providerID == $m.providerID and .id == $m.id) | .limit.context][0] // null')"

  jq -c -n \
    --arg skill "$skill" --arg at "$(now_iso)" \
    --argjson s "$s" --argjson b "$baseline" --argjson subs "$subs" \
    --argjson peak "$peak" --argjson limit "$limit" --argjson missing "$baseline_missing" '
    def tok(t): {
      input: (t.input // 0), output: (t.output // 0), reasoning: (t.reasoning // 0),
      cacheRead: (t.cache.read // 0), cacheWrite: (t.cache.write // 0) };
    def add(a; b): reduce (a | keys_unsorted[]) as $k ({}; .[$k] = a[$k] + b[$k]);
    def sub(a; b): reduce (a | keys_unsorted[]) as $k ({}; .[$k] = a[$k] - b[$k]);
    (sub(tok($s.tokens); tok($b.tokens))) as $main
    | (reduce $subs[] as $c (tok({}); add(.; tok($c.tokens)))) as $child
    | add($main; $child) as $t
    | {
        available: true,
        skill: $skill,
        sessionID: $s.id,
        generatedAt: $at,
        model: $s.model,
        costUSD: (((($s.cost // 0) - ($b.cost // 0)) + ([$subs[].cost // 0] | add // 0)) * 10000 | round / 10000),
        tokens: ($t + {total: ($t | add)}),
        context: {
          peak: $peak,
          limit: $limit,
          percent: (if $limit and $limit > 0 then ($peak * 1000 / $limit | round / 10) else null end)
        },
        subagentSessions: ($subs | length),
        partial: true
      }
      + (if $missing then {baselineMissing: true} else {} end)'
  rm -f "$baseline_file"
}

cmd_log() {
  have jq || { echo "usage.sh log: jq is not installed" >&2; exit 1; }
  local event="${1:-}"
  [ -n "$event" ] || event="$(cat)"
  local line
  line="$(printf '%s' "$event" | jq -c -e \
    --arg ts "$(now_iso)" --arg sid "$SID" '
    select(type == "object" and (.event | type) == "string")
    | {schemaVersion: 1, event, timestamp: (.timestamp // $ts),
       sessionID: (.sessionID // (if $sid == "" then null else $sid end))}
      + del(.schemaVersion, .event, .timestamp, .sessionID)' 2>/dev/null)" || {
    echo 'usage.sh log: the event must be a JSON object with an "event" string' >&2
    exit 1
  }
  mkdir -p "$DATA_DIR" && printf '%s\n' "$line" >>"$LOG_FILE" || {
    echo "usage.sh log: could not write $LOG_FILE" >&2
    exit 1
  }
  echo "$LOG_FILE"
}

case "${1:-}" in
  start) cmd_start ;;
  report) shift; cmd_report "$@" ;;
  log) shift; cmd_log "$@" ;;
  path) echo "$LOG_FILE" ;;
  *)
    echo "Usage: usage.sh start | report <skill> | log '<event-json>' | path" >&2
    exit 2
    ;;
esac
