---
name: Review Coding Challenge
description: Review a learner's solution to a coding challenge made by create-coding-challenge. Runs the visible tests, generates and runs hidden edge-case tests (intermediate/advanced), checks the code against the rubric, and gives level-appropriate feedback that names knowledge gaps and next steps. Use when the learner asks for a review, feedback, grading, or to check their challenge solution.
---

# Review Coding Challenge

Review the learner's solution to a challenge created by `create-coding-challenge`
and help them close knowledge gaps. This skill **reads and runs** the learner's
code. It never edits their files and never gives them the full solution unless
they ask for it.

Paths below are relative to this skill's directory (`<skill-dir>`). Shared
scripts and references live in the paired skill:
`<create-skill-dir>` = `<skill-dir>/../create-coding-challenge`.

## Workflow

### Step 1: Find the challenge

1. Look for `.challenge/meta.json` in the current directory, then in its direct
   subfolders. If the learner named a folder, use that one.
2. If several challenges are found, ask which one to review. If none is
   found, tell the learner this skill needs a challenge made by
   `create-coding-challenge` and stop.
3. Read `.challenge/meta.json`, `.challenge/rubric.md`, `assignment.md`, the
   visible tests, and the learner's code (`entryPoints` plus any files they added).

### Step 2: Check the environment

```sh
bash "<create-skill-dir>/scripts/check-env.sh" <meta.language>
```

If it reports `NOT READY`, follow the same stop-and-guide procedure as
`create-coding-challenge` Step 2, using `<create-skill-dir>/references/toolchains.md`:
explain what's missing, give the OS-specific steps, leave **[user]** steps to
the learner, and offer to run **[agent]** steps only after explicit
confirmation. Re-check before continuing.

Run every toolchain command with the version managers loaded:

```sh
. "<create-skill-dir>/scripts/env.sh" && cd <challenge-dir> && <command>
```

If dependencies are missing (for example no `node_modules` or `.venv`), run
`meta.setupCommand` first. It is project-local.

### Step 3: Run the visible tests

Run `meta.testCommand` in the challenge folder and record passed/failed per
test (test names start with their AC ID). If the code doesn't compile or the
tests can't run, that becomes the first issue in the feedback. Explain the
error at the learner's level and skip Step 4.

Also check that the learner did **not** change the visible tests or the public
API they rely on. Compare them with what `assignment.md` and the rubric
describe. If they did, say so and judge the solution against the original
criteria.

### Step 4: Generate and run hidden tests (intermediate/advanced only)

Only if `meta.hiddenTests.enabled` is `true`. Follow `references/hidden-tests.md`:

- Generate tests in a **temporary copy** only, for the ACs in
  `hiddenTests.criteria`, following each AC's hidden-focus category, with the
  number of tests set by the level.
- Each test must follow strictly from the written AC.
- **Check every failure** against the AC text before counting it. Discard any
  test that is wrong or debatable.
- Delete the temp copy afterwards. Never leave hidden tests in the challenge folder.

Beginner challenges have no hidden tests.

### Step 5: Review the code against the rubric

Assess, in this order:

1. **Correctness**: which ACs are met, using test results plus reading the code
   (tests can't prove everything, for example a hard-coded answer).
2. **Concepts**: whether the learning goals were applied the intended way. Use
   the rubric's gap-signals table.
3. **Quality**: against the rubric's "Quality expectations" for the level
   (naming, structure, error handling, idiomatic language/framework use).
   Respect "Out of scope".

### Step 6: Find knowledge gaps

Follow "Finding knowledge gaps" in `references/feedback-guide.md`: match the
findings to concepts, separate repeated or root-cause **gaps** from one-off
**slips**, and give one official resource per gap.

### Step 7: Give feedback

Use the output template and the level's tone from `references/feedback-guide.md`:
status, test counts, AC table, what went well, ranked issues, knowledge gaps,
next steps, and an optional follow-up challenge suggestion (to be created with
`create-coding-challenge` if the learner asks).

Describe failed hidden cases in plain language. Don't paste hidden test code
or exact inputs unless the learner asks.

## Rules

- Never modify the learner's files, the visible tests, `assignment.md`, or `.challenge/`.
- Never store hidden tests or reference solutions in the challenge folder.
- Never give the full solution or rewrite the learner's code unless they
  explicitly ask. Then provide it and still explain the gaps it addresses.
- If the learner asks follow-up questions, answer at the level's depth. Guide
  them toward the fix rather than writing it.
- If the learner fixes their code and asks again, run the full review again
  (hidden tests are regenerated each time).

## References

- `references/hidden-tests.md`: when and how to generate, verify and discard hidden tests
- `references/feedback-guide.md`: tone per level, gap analysis, status rules, output template
- `<create-skill-dir>/scripts/check-env.sh`, `<create-skill-dir>/scripts/env.sh`: environment check and loading
- `<create-skill-dir>/references/toolchains.md`: installation guidance
- `<create-skill-dir>/references/test-runners.md`: runners and the temp-copy procedure
- `<create-skill-dir>/references/challenge-format.md`: `meta.json` and `rubric.md` formats
