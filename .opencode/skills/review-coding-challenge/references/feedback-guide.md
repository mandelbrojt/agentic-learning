# Feedback guide

Feedback has one purpose: help the learner **close knowledge gaps** and improve
the solution **themselves**.

## Ground rules

- Don't rewrite the learner's solution, and don't give a full corrected version,
  unless the learner explicitly asks for it.
- Don't edit the learner's files. The review only reads them.
- Be specific: point to the file and line (`src/cart.ts:14`) and to the AC.
- Be honest and kind: name what is wrong clearly, without sarcasm or vague praise.
- Rank problems: correctness before concepts before quality before style.
- Respect the rubric's "Out of scope" list. Don't penalize what the level doesn't ask for.

## Tone and depth by level

| Level | How to explain | Code in feedback |
|---|---|---|
| Beginner (1–4) | Explain *what* is wrong, *why* it happens, and *which concept* fixes it. Use simple words, one idea at a time. Encourage. | Small snippets (1–5 lines) that show the concept on **different data** than the challenge. Never the function body. |
| Intermediate (5–7) | Point to the issue and explain the reason. Ask a guiding question when it helps ("What happens when the cart is empty?"). | Only API names or one-line idioms. |
| Advanced (8–10) | Short, peer code-review style. Discuss trade-offs (complexity, readability, failure modes, extensibility). | Rarely; only names or signatures. |

## Finding knowledge gaps

1. Start from the facts: failing tests (visible and hidden), unmet ACs, and code
   observations.
2. Match each finding to a concept with the rubric's "Concepts and knowledge-gap
   signals" table. If nothing matches, name the underlying concept yourself
   (for example "floating-point arithmetic", "reference vs. value", "async error propagation").
3. Separate **gaps** (a misunderstood concept that shows up repeatedly or at
   the root of a failure) from **slips** (a one-off typo or oversight). Only
   gaps go under "Knowledge gaps".
4. For each gap, give: the concept, the evidence in their code, a one-sentence
   explanation, and one official resource (language or framework docs).

## Status

| Status | Meaning |
|---|---|
| ✅ **Passed** | All visible and hidden tests pass, and every AC is met. |
| 🟡 **Almost there** | All visible tests pass but some hidden tests fail, or there are important concept/quality issues for the level. |
| 🔴 **Not yet** | Visible tests fail, the code doesn't compile/run, or ACs are unmet. |

## Output template

```markdown
## Review: <Challenge title> (<Level>, <difficulty>/10)

**Status:** <✅ Passed | 🟡 Almost there | 🔴 Not yet>
**Tests:** visible <x>/<y> · hidden <x>/<y> (or "none at this level")
**Acceptance criteria met:** <n>/<m>

| AC | Result | Notes |
|----|--------|-------|
| AC1 | ✅ | |
| AC2 | ❌ | <one line, for example "fails when the cart is empty (hidden)"> |

### What went well
- <specific strength tied to a learning goal>

### Issues (most important first)
1. **<title>** (AC<n>, `<file>:<line>`)
   <what's wrong, why, which concept, at the level's depth>

### Knowledge gaps
- **<concept>**: <evidence>. <one-sentence explanation>. Learn more: <official link>

### Next steps
1. <concrete action to fix the most important issue, without the solution>
2. <concept to study or practice>
3. Optional follow-up challenge: <suggested topic> at difficulty <n> (ask me to create it).
```

For the follow-up challenge: same difficulty if the status is "Not yet" (focus
on the gap); +1 or +2 if "Passed"; same difficulty with a different scenario if
"Almost there". Suggest; don't create it unless the learner asks.
