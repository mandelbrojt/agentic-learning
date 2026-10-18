# Challenge format

Every challenge is a folder in the directory where OpenCode was started:

```
<challenge-name>/
  assignment.md          what the learner reads
  <starter code>         framework/language standard layout (src/, lib/, ...)
  <visible tests>        tests/, spec/, src/test/, *_test.go ...
  <project config>       package.json, pyproject.toml, go.mod, build.gradle.kts ...
  <version pin file>     .nvmrc, .python-version, .sdkmanrc ...
  .gitignore
  .challenge/
    meta.json            machine-readable metadata (used by review-coding-challenge)
    rubric.md            review rubric (used by review-coding-challenge)
```

Nothing else. No solution files, no hidden tests, no generated build output.

---

## `assignment.md`

Keep it short, direct and imperative. Use exactly these sections in this order.
Optional sections are marked.

```markdown
# <Challenge title>

**Level:** <Beginner|Intermediate|Advanced> (<difficulty>/10) · **Language:** <language> · **Framework:** <framework or "none">

## Context
<1–3 sentences: fictional company, who needs this, why. Realistic.>

## Goal
<One sentence describing the outcome.>

## What you'll practice            <!-- beginner and intermediate only -->
- <concept 1>
- <concept 2>

## Acceptance criteria
- **AC1**: <objective, testable statement with exact names/values>.
  Example: `<input>` → `<output>`          <!-- examples: every AC at beginner, some at intermediate, only when needed at advanced -->
- **AC2**: ...

## Step by step                     <!-- beginner only -->
1. <instruction that maps to an AC, naming the file and function>
2. ...

**Hints**
- <hint>
- Docs: [<feature>](<official docs link>)

## Tips                             <!-- intermediate only, max 2 -->
- <tip>

## Constraints                      <!-- advanced (optional for intermediate) -->
- <constraint, for example no external libraries, complexity or time budget, public API that must not change>
- <what is left to the learner's judgment and what tests do not check>

## Files
- `<path>`: <what the learner edits here>
- `<path>`: tests (read them, but don't change them)

## Run the tests
<setup command, run once>
<test command>

<intermediate/advanced only:>
Additional tests for these acceptance criteria run when you ask for a review.

## Done when
All tests pass and every acceptance criterion is met. Then ask for a review to get feedback.
```

Rules:

- AC IDs (`AC1`, `AC2`...) are stable and are used in test names, the rubric,
  and review feedback.
- Every rule the tests check appears in an AC. Every AC is tested (visible tests, hidden tests at review time, or both).
- Don't show solution code. Beginner hints may name a language feature or show
  a one-line idiom; they must not give the function body.
- Code identifiers in backticks, exact spelling.

---

## `.challenge/meta.json`

```json
{
  "schemaVersion": 1,
  "id": "cart-total-calculator",
  "title": "Cart Total Calculator",
  "language": "typescript",
  "languageVersion": "24",
  "framework": null,
  "difficulty": 3,
  "level": "beginner",
  "domain": "e-commerce checkout",
  "concepts": ["arrays", "loops", "number rounding"],
  "entryPoints": ["src/cart.ts"],
  "visibleTests": ["tests/cart.test.ts"],
  "setupCommand": "npm install",
  "testCommand": "npm test",
  "versionFile": ".nvmrc",
  "hiddenTests": {
    "enabled": false,
    "criteria": [],
    "location": "tests/hidden.test.ts"
  },
  "createdAt": "2026-10-17",
  "generation": {
    "skill": "create-coding-challenge",
    "sessionID": "ses_…",
    "generatedAt": "2026-10-17T14:03:00Z",
    "model": { "id": "claude-opus-5-5", "providerID": "opencode", "variant": "default" },
    "costUSD": 0.5337,
    "tokens": { "input": 556, "output": 9062, "reasoning": 2612, "cacheRead": 362493, "cacheWrite": 45564, "total": 420287 },
    "context": { "peak": 152000, "limit": 1000000, "percent": 15.2 },
    "subagentSessions": 0,
    "partial": true
  }
}
```

Field notes:

- `language`: lowercase canonical name used by `scripts/check-env.sh`
  (`javascript`, `typescript`, `python`, `java`, `kotlin`, `go`, `rust`, `ruby`, `csharp`, `php`, or other).
- `framework`: lowercase name (`react`, `express`, `fastapi`, `spring-boot`...) or `null`.
- `level`: derived from `difficulty` (1–4 beginner, 5–7 intermediate, 8–10 advanced).
- `entryPoints`: files the learner is expected to edit.
- `hiddenTests.enabled`: `false` for beginner, `true` for intermediate/advanced.
- `hiddenTests.criteria`: AC IDs that get extra edge-case tests at review time.
- `hiddenTests.location`: where, inside the temporary copy, the reviewer puts the generated hidden test file (see `test-runners.md`).
- `generation`: what generating the challenge cost. It is the output of
  `learning-stats/scripts/usage.sh report create-coding-challenge` without the
  `available` field, added last (SKILL.md Step 8). Leave it out when usage was
  unavailable. Field meanings are in `../../learning-stats/references/events.md`.
  It's for statistics only: never show it in `assignment.md`.

---

## `.challenge/rubric.md`

The rubric guides the reviewer. The learner can open it, so it must **not**
contain solution code or concrete hidden-test inputs. Describe *what* is
checked, not *with which data*.

```markdown
# Rubric: <Challenge title>

## Learning goals
- <goal 1, phrased as a skill: "Narrow an `unknown` value with `typeof` and `Array.isArray`">
- <goal 2>

## Acceptance criteria map
| AC | Criterion (short) | Visible tests | Hidden at review | Hidden focus (category only) |
|----|-------------------|---------------|------------------|------------------------------|
| AC1 | <short text> | `AC1: ...`, `AC1: ...` | no | — |
| AC2 | <short text> | `AC2: ...` | yes | boundary values |
| AC3 | <short text> | `AC3: ...` | yes | invalid input / error path |

Categories to use: boundary values, empty input, invalid input / error path,
large input / performance, ordering / stability, precision / rounding,
concurrency / timing, unicode / formatting, state transitions.

## Concepts and knowledge-gap signals
| Concept | Signals that the learner understands it | Signals of a gap (common mistakes) |
|---------|------------------------------------------|------------------------------------|
| <concept> | <observable in code> | <mistake> → <what it reveals> |

## Quality expectations (<level>)
- <expectation suited to the level: naming, small functions, no mutation of inputs, error types, idiomatic framework usage...>

## Out of scope
- <things the reviewer must not penalize (for example performance at beginner level, styling in a logic challenge)>
```
