# Learning statistics: usage and the central log

Shared by every agentic-learning skill that records usage or statistics
(`create-coding-challenge` today, lessons and reviews later).

Script: `scripts/usage.sh` (relative to this skill's directory, `<stats-dir>`).

## Where the data lives

```
${AGENTIC_LEARNING_DATA_DIR:-${XDG_DATA_HOME:-~/.local/share}/agentic-learning}/
  events.jsonl                 central log: one JSON event per line, append-only
  baselines/<sessionID>.json   temporary, between `usage.sh start` and `usage.sh report`
```

The log is per user, not per project: it collects every event from every folder
where OpenCode runs. Print its path with `bash "<stats-dir>/scripts/usage.sh" path`.

## Measuring usage in a skill

1. At the start of the skill's work: `bash "<stats-dir>/scripts/usage.sh" start`.
2. When the work is done: `bash "<stats-dir>/scripts/usage.sh" report <skill-id>`.
   It prints the usage since `start` as one JSON object (the **usage block**).
3. Store the usage block where the skill's format says (for example
   `meta.json`) and append an event with `usage.sh log`.

If the output has `"available": false`, usage couldn't be read (not running
inside OpenCode, `jq` missing, API unavailable). **Never stop the skill for
this.** Skip storing usage, still log the event without `usage`, and mention the
reason to the user in one line.

### Usage block

```json
{
  "available": true,
  "skill": "create-coding-challenge",
  "sessionID": "ses_…",
  "generatedAt": "2026-10-18T14:03:00Z",
  "model": { "id": "claude-opus-5-5", "providerID": "opencode", "variant": "default" },
  "costUSD": 0.5337,
  "tokens": { "input": 556, "output": 9062, "reasoning": 2612, "cacheRead": 362493, "cacheWrite": 45564, "total": 420287 },
  "context": { "peak": 152000, "limit": 1000000, "percent": 15.2 },
  "subagentSessions": 0,
  "partial": true
}
```

- `model`: the session's model when `report` runs.
- `costUSD`: estimated cost since `start`, from OpenCode's model prices,
  including subagent sessions started since `start`. Not a provider invoice.
- `tokens`: totals since `start`, including subagent sessions. `total` is the
  sum of all token fields.
- `context.peak`: the largest context (input + cache read + cache write) sent
  in a single model step of the main session since `start`. `limit` is the
  model's context window; `percent` = `peak / limit × 100`, one decimal.
  `limit` and `percent` are `null` when the model's limit is unknown.
- `subagentSessions`: number of subagent sessions included.
- `partial`: always `true`. The steps after `report` (writing the files, the
  final message) aren't counted. They usually cost a few cents.
- `baselineMissing: true` (only when present): `start` wasn't run, so the
  numbers cover the whole session.

## Central log: `events.jsonl`

Append with `bash "<stats-dir>/scripts/usage.sh" log '<event-json>'`. The script
adds `schemaVersion`, `timestamp` and `sessionID` when they are missing,
checks that the event is a JSON object with an `event` string, and appends one
line. Never edit or rewrite existing lines.

### Envelope (all events)

| Field | Type | Notes |
|---|---|---|
| `schemaVersion` | number | `1` |
| `event` | string | `<subject>.<past-tense verb>`, for example `challenge.generated` |
| `timestamp` | string | ISO 8601 UTC |
| `sessionID` | string \| null | OpenCode session |
| `subject` | object | What the event is about. Always has `type` and `id`. |
| `usage` | object | Optional. The usage block without `available`, `skill` and `sessionID`. |

Event types may add their own top-level fields (for example `result`).

### Event types

#### `challenge.generated`

Logged by `create-coding-challenge` after the challenge passes its checklist.

```json
{
  "event": "challenge.generated",
  "skill": "create-coding-challenge",
  "subject": {
    "type": "challenge",
    "id": "cart-total-calculator",
    "title": "Cart Total Calculator",
    "path": "/home/me/learning/cart-total-calculator",
    "language": "typescript",
    "framework": null,
    "difficulty": 3,
    "level": "beginner",
    "domain": "e-commerce checkout",
    "concepts": ["arrays", "loops", "number rounding"]
  },
  "usage": { "generatedAt": "…", "model": { … }, "costUSD": 0.5337, "tokens": { … }, "context": { … }, "subagentSessions": 0, "partial": true }
}
```

`subject` fields come from `.challenge/meta.json`; `path` is the absolute path
of the challenge folder.

#### Reserved for later

- `lesson.generated`: a lesson created from a roadmap. `subject.type: "lesson"`.
- `challenge.reviewed`: a review of a learner's solution. `subject` identifies
  the challenge; a `result` field holds the outcome (status, passed/failed ACs,
  attempt number, knowledge gaps).

Add new event types to this file before logging them.

## Example queries

```sh
LOG="$(bash "<stats-dir>/scripts/usage.sh" path)"
# Total spent generating challenges
jq -s '[.[] | select(.event == "challenge.generated") | .usage.costUSD // 0] | add' "$LOG"
# Most used model
jq -rs '[.[] | .usage.model | select(.) | "\(.providerID)/\(.id)"] | group_by(.) | map({model: .[0], count: length}) | max_by(.count)' "$LOG"
# Most expensive challenge
jq -s '[.[] | select(.event == "challenge.generated")] | max_by(.usage.costUSD // 0) | {id: .subject.id, costUSD: .usage.costUSD}' "$LOG"
```
