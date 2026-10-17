# Generating hidden tests at review time

Hidden tests exist only during a review. They are never written into the
challenge folder and are deleted after the run.

## When to generate

- `meta.json` → `hiddenTests.enabled` is `true` (intermediate or advanced level).
- Only for the ACs in `hiddenTests.criteria` (also marked "yes" in the rubric's AC map).
- Beginner challenges: no hidden tests. Review with visible tests and code reading only.

## How many

| Level | Hidden tests in total |
|---|---|
| Intermediate (5–7) | 3–6 |
| Advanced (8–10) | 6–12 |

Spread them across the hidden-flagged ACs and follow each AC's "Hidden focus"
category from the rubric (boundary values, empty input, error path, large
input / performance, ordering, precision, concurrency, unicode, state transitions).

## Rules for every hidden test

1. **Derived only from written criteria.** The expected result must follow
   directly from the AC text in `assignment.md`, without assumptions. If the
   AC doesn't define the expected behavior for an input, don't test that input.
2. **Uses only the public API** that the visible tests use (same imports,
   entry points, endpoints, components). Don't depend on the learner's internal helpers.
3. **Same runner and style** as the visible tests. Name each test
   `AC<n> [hidden]: <behavior>`.
4. **Deterministic**: no randomness without a fixed seed, no real time (use
   injected clocks or fixed dates when the API allows), no network.
5. **Performance tests** (only if an AC states a measurable budget): use the
   AC's budget plus a reasonable margin for machine variance, and note the
   measured time in the feedback.
6. **One behavior per test**, so a failure maps to one criterion and one category.

## Procedure

1. Create a temp copy following "Running extra tests in a temporary copy" in
   `<create-skill-dir>/references/test-runners.md`.
2. Write the hidden test file at `hiddenTests.location` inside the temp copy.
3. Run only the hidden file if the runner supports it (for example `npx vitest run tests/hidden.test.ts`,
   `python -m pytest tests/test_hidden.py`, `go test -run Hidden ./...`, `cargo test --test hidden`),
   otherwise run the full `testCommand`.
4. **Check every failure before blaming the learner.** The reference solution
   was deleted when the challenge was created, so a generated test can be wrong. For each failing hidden test:
   - Re-read the AC. Does the expected value follow strictly from its text?
   - Re-compute the expected value by hand.
   - Check that the test uses the API exactly as the assignment describes.
   - If the test is wrong or debatable, **discard it** and don't report it as
     a learner failure. If it shows that the AC itself is ambiguous, mention
     that the assignment could be clearer.
5. Record for each kept test: AC, category, pass/fail, and a **plain-language
   description** of the scenario (for example "an order where two discount codes
   give the same saving"). Don't paste the hidden test code or exact inputs
   into the feedback unless the learner asks.
6. Delete the temp copy (`rm -rf`).

Hidden tests are regenerated on every review, so the exact cases can differ
between runs. Because they only check written criteria, a correct solution
passes them every time.
