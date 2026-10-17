---
name: Create Coding Challenge
description: Generate a practical, real-world coding challenge (assignment, starter code, runnable tests, review rubric) in a chosen programming language and framework at difficulty 1-10. Checks that the required toolchain is installed first. Use when the user asks for a coding challenge, exercise, kata, or practice task.
---

# Create Coding Challenge

Generate a coding challenge the learner solves by **writing code** to fix a
**real-world problem**, and checks with **runnable tests**. A paired skill,
`review-coding-challenge`, later reviews the learner's solution, so every
challenge also includes review metadata.

Paths below are relative to this skill's directory (`<skill-dir>`).

## Principles (always apply)

1. **Practical**: every challenge comes from a realistic product scenario. No
   abstract puzzles. See `references/real-world-domains.md`.
2. **Always testable**: every challenge ships with tests the learner runs with
   one command, using the ecosystem's standard test runner. See `references/test-runners.md`.
3. **Always clear**: the goal and acceptance criteria are objective at every
   difficulty. Harder means **less guidance**, never less clarity. See `references/difficulty-levels.md`.
4. **The learner writes the code**: starter code has structure only (types,
   signatures, placeholders). Never ship a solution.
5. **Runs on this machine**: never generate a challenge whose toolchain is
   missing. Check first, then guide the installation.
6. **The original example is a guide, not a template**: `references/example/NOTES.md`
   explains which ideas to keep and what to do differently.

## Workflow

### Step 1: Collect the inputs

Required. **Always ask** for any that are missing (use the question tool, in
one round when possible). Never assume defaults.

| Input | Rules |
|---|---|
| Language | Required. |
| Framework | Ask when the language has common frameworks for the topic. `none` is a valid answer. |
| Difficulty | Required. Integer 1–10. Map it to a level: 1–4 beginner, 5–7 intermediate, 8–10 advanced. |
| Topic | A concept (for example "async retries"), a domain (for example "billing"), or "surprise me". Ask if missing, and offer 3–4 options from `references/real-world-domains.md` that fit the language, framework and level. |

If a value is invalid (for example difficulty 12, or a framework that doesn't
belong to the language), explain and ask again.

### Step 2: Check the environment

Before writing any file:

```sh
bash "<skill-dir>/scripts/check-env.sh" <language>
```

- Exit `0` (`READY`): continue. Mention any warnings briefly.
- Exit `1` (`NOT READY`): **stop. Do not create the challenge.** Then:
  1. Show the user a short report: each missing item, why the challenge needs it,
     and the detected OS.
  2. Give the exact install steps for this OS from `references/toolchains.md`,
     using the recommended version manager (nvm, pyenv, SDKMAN!, rustup, rbenv...).
  3. Steps tagged **[user]** (`sudo`, rc-file edits, remote installers that edit
     shell profiles): show the commands and ask the user to run them in their
     own terminal. Never run them yourself.
  4. Steps tagged **[agent]** (user-level installs such as `nvm install --lts`
     or `pyenv install 3.12`): **offer** to run them and run them only after the
     user explicitly confirms. Use `. "<skill-dir>/scripts/env.sh" && <command>`
     and a long timeout.
  5. Re-run `check-env.sh` after installation. Continue only when it reports `READY`.
- Exit `2` (unknown language): check it manually using the "Other languages"
  section of `references/toolchains.md`, and apply the same stop-and-guide rules.

Framework packages are not system requirements: they are installed per project
in Step 6. If a framework needs extra **system** tools (for example a browser or
a database server), redesign the challenge to avoid them (jsdom, SQLite in
memory, fakes) rather than requiring installs.

**Every** later shell command that uses the language toolchain must load the
version managers first, because agent shells do not read `~/.zshrc`:

```sh
. "<skill-dir>/scripts/env.sh" && cd <challenge-dir> && <command>
```

### Step 3: Design the challenge

Read `references/difficulty-levels.md` and `references/real-world-domains.md`, then decide:

1. **Scenario**: fictional company, stakeholder and problem (1–3 sentences).
2. **Learning goals**: how many depends on the level (beginner 1, intermediate 1–2, advanced 2–3).
3. **Acceptance criteria** `AC1..ACn`: objective and testable, with exact
   names, types, values, formats, errors. The count depends on the level.
4. **Public API**: the files, types and function/class/endpoint/component
   signatures the tests use.
5. **Test plan**: for each AC, which visible tests check it. For intermediate
   and advanced levels, which ACs get hidden edge-case tests at review time,
   and the *category* of edge case (never the concrete inputs).
6. **Challenge folder name**: kebab-case after the scenario. Create it in the
   **current working directory** (where OpenCode was started). If the folder
   already exists, ask the user whether to pick a new name or overwrite.

Self-check before writing: is it realistic? Is every rule in an AC? Does every
AC have a test? Is the guidance right for the level?

### Step 4: Write the files

Follow `references/challenge-format.md` exactly:

- `assignment.md`: sections and guidance per level.
- Starter code in the standard layout of the language and framework (`references/test-runners.md`):
  - Beginner: all files, types and signatures; TODO comments that mirror the
    "Step by step" list; placeholder body.
  - Intermediate: types and public signatures; placeholder body.
  - Advanced: only the public entry point/interface the tests use.
  - The placeholder must **compile** and fail at runtime (`throw new Error("Not implemented")`, `raise NotImplementedError`, `todo!()`...).
- Visible tests using the ecosystem's standard runner. Prefix each test name
  with its AC ID. Check each output field or behavior separately so a failure
  points at one thing. Beginner: one behavior per test, and every test is visible.
- Project config with a single setup command and a single test command,
  a version pin file matching the version reported by `check-env.sh`, and a `.gitignore`.
- `.challenge/meta.json` and `.challenge/rubric.md`.

Style: match each ecosystem's conventions (formatting, naming, file layout).
Use realistic test data. Light, work-safe humor is welcome.

### Step 5: Install the project dependencies

Run `setupCommand` inside the challenge folder (project-local only, for example
`npm install`, or creating `.venv` and running `pip install`). This is part of
creating the challenge and doesn't need extra confirmation. Never install
packages globally.

### Step 6: Verify with a throwaway solution

The challenge folder must never contain solution code. Follow "Running extra tests in a temporary copy" in `references/test-runners.md`:

1. **The starter fails as expected**: run `testCommand` in the challenge folder.
   The tests must run (no compile, import or syntax errors) and fail because of
   the placeholder. For typed languages, also type-check the starter (for example
   `npx tsc --noEmit`, `go vet ./...`, `cargo check`).
2. **The tests can pass**: in a temp copy, write a correct reference solution
   in the entry-point files and run `testCommand`. Every visible test must pass.
3. **The hidden criteria are testable** (intermediate/advanced): in the same
   temp copy, write draft edge-case tests for each hidden-flagged AC and run
   them against the reference solution. If a draft test is ambiguous or can't be
   derived from the AC text alone, rewrite the AC until it can. Discard the drafts.
4. If anything fails, fix the challenge (not the expectations of the AC) and repeat.
5. Delete the temp copy (`rm -rf`) so no solution or draft test remains.

### Step 7: Final checklist

Confirm every item before reporting:

- [ ] The scenario is realistic. No abstract puzzle.
- [ ] Inputs respected: language, framework, difficulty → level.
- [ ] `check-env.sh` reported READY, and the version pin file matches.
- [ ] `assignment.md` has every required section; guidance matches the level; the goal is one clear sentence.
- [ ] Every AC is objective, has at least one test, and every test maps to an AC.
- [ ] Names match exactly across `assignment.md`, starter code, tests and rubric.
- [ ] Starter code compiles and fails only because of placeholders. No solution logic anywhere.
- [ ] No hidden tests and no solution files in the challenge folder.
- [ ] `meta.json` is valid JSON; `hiddenTests.enabled` is `false` for beginner and `true` otherwise, and lists the right ACs.
- [ ] `rubric.md` has no solution code and no concrete hidden inputs.
- [ ] The challenge runs offline with one setup command and one test command.

### Step 8: Report to the user

Keep it short:

- Challenge folder path and title, level (difficulty), language/framework.
- One-line scenario and learning goals.
- How to start: `cd <folder>`, open `assignment.md`, run `<testCommand>`.
- Remind them to ask for a review (the `review-coding-challenge` skill) when they're done.

Don't reveal the solution or describe how to solve it.

## References

- `scripts/check-env.sh`: environment check (exit 0 ready, 1 missing, 2 unknown language)
- `scripts/env.sh`: source before any toolchain command
- `references/toolchains.md`: version managers, install steps per OS, [agent]/[user] tags
- `references/difficulty-levels.md`: level matrix, clarity rules, the same task at 3 levels
- `references/real-world-domains.md`: realism checklist and scenario bank
- `references/test-runners.md`: runners, layouts, placeholders, temp-copy procedure
- `references/challenge-format.md`: `assignment.md`, `meta.json`, `rubric.md` formats
- `references/example/`: the original example and `NOTES.md`
