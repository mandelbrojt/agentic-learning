# Difficulty levels

The user gives a difficulty from **1 to 10**. Map it to a level:

| Difficulty | Level |
|---|---|
| 1–4 | **Beginner** |
| 5–7 | **Intermediate** |
| 8–10 | **Advanced** |

Difficulty changes **how much guidance** the learner gets and **how much of the
problem they must design themselves**. It never changes **how clear** the goal
and acceptance criteria are. At every level the learner must be able to read
`assignment.md` and know exactly what "done" means.

Inside a level, the exact number adjusts scope: a 1 is one small function with
two or three criteria; a 4 is several related functions or a small module. A 5
adds error handling and edge cases; a 7 coordinates a few components. An 8 asks
for a small design with constraints; a 10 combines design, performance or
concurrency, and failure handling.

## Level matrix

| Aspect | Beginner (1–4) | Intermediate (5–7) | Advanced (8–10) |
|---|---|---|---|
| Learning goals | 1 concept | 1–2 related concepts | 2–3 concepts plus design decisions |
| Scope | 1–3 functions, ~10–40 lines of solution | a module or a few functions/classes, ~40–150 lines | a small component/service, ~150+ lines, learner chooses internals |
| Acceptance criteria | 2–5, each very concrete | 4–8, including error/edge behavior | 5–12, including constraints (performance, errors, concurrency, API contracts) |
| Guidance section | **Step-by-step** numbered instructions mapped to criteria, plus 1–3 hints and links to relevant language docs | **Tips**: at most 2 short hints, no step list | **None.** Only a "Constraints" list; the learner chooses the approach |
| Examples in assignment | Input → output example for each criterion | 1–2 representative examples | Examples only where needed to remove ambiguity (formats, contracts) |
| Starter code | All files, types and signatures; a single `Write your solution here` comment where the learner writes code | Types and public signatures; a single `Write your solution here` comment where the learner writes code | Only the public entry point / interface the tests use, with a single `Write your solution here` comment; the learner creates internal helpers, files and types |
| Visible tests | **All** tests visible; one behavior per test; descriptive names | Main behavior of every criterion visible | Smoke tests for each criterion (happy paths) |
| Hidden tests (generated at review time) | **None** | A few edge cases (3–6) for the criteria marked hidden | More edge cases, error paths and limits (6–12) |
| Feedback tone at review | Detailed, explains why, small illustrative snippets | Points to the issue and explains the reason | Short, peer-review style, discusses trade-offs |

**Hidden-test rule:** a hidden test may only check a behavior that is **written
in an acceptance criterion**. Hiding a test hides the *example*, never the
*requirement*. If a hidden edge case is important, the criterion must state the
expected behavior for that class of input (for example, "an empty cart returns a
total of 0").

## Clarity rules (all levels)

- One-sentence **Goal** that states the outcome, not the technique.
- Each acceptance criterion is objective and testable: exact names, types,
  return values, error types/messages, formats, rounding rules, ordering.
- Never use vague words such as "handle properly", "efficient", "clean", "robust"
  without a measurable definition (for example "must process 100,000 records in
  under 1 second on the test machine" or "throws `ValidationError` with message
  `quantity must be positive`").
- Names in `assignment.md`, starter code and tests must match exactly.
- If a decision is left to the learner (advanced), say explicitly that it is
  their choice and what the tests will and will not check.

## Same task at three levels

Real-world context used for all three: **Cartly**, an online store, needs to
compute order totals at checkout. The samples below show only the parts of
`assignment.md` that change between levels.

### Beginner (difficulty 2)

> ## Goal
> Write a function that calculates the total price of a shopping cart.
>
> ## Acceptance criteria
> - **AC1**: `calculateTotal(items)` returns the sum of `price * quantity` for every item.
>   Example: `[{ price: 10, quantity: 2 }, { price: 5, quantity: 1 }]` → `25`.
> - **AC2**: An empty cart returns `0`.
> - **AC3**: The result is rounded to 2 decimal places.
>   Example: `[{ price: 0.1, quantity: 3 }]` → `0.3`.
>
> ## Step by step
> 1. Open `src/cart.ts`. The `CartItem` type is already defined for you.
> 2. Create a variable `total` that starts at `0`.
> 3. Loop over `items` (a `for...of` loop works well) and add `item.price * item.quantity` to `total`.
> 4. Return `total` rounded to 2 decimals. Hint: `Math.round(total * 100) / 100`.
> 5. Run `npm test` and fix any failing test.
>
> **Hints**
> - An empty array never enters the loop, so `total` stays `0` (AC2 comes for free).
> - Docs: [for...of](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Statements/for...of)

Starter: `CartItem` type and `calculateTotal` signature; the body has only
`// Write your solution here` and `return 0;` (needed to type-check).

### Intermediate (difficulty 6)

> ## Goal
> Implement `calculateTotal(cart)` so checkout shows the correct amount after discounts and tax.
>
> ## Acceptance criteria
> - **AC1**: Subtotal is the sum of `price * quantity` for every line.
> - **AC2**: A `discountCode` of `SAVE10` takes 10% off the subtotal; `FREESHIP` sets shipping to `0`; an unknown code throws `InvalidDiscountError`.
> - **AC3**: Shipping is `4.99` when the discounted subtotal is under `50`, otherwise `0`.
> - **AC4**: Tax is `8%` of (discounted subtotal + shipping).
> - **AC5**: Returns `{ subtotal, discount, shipping, tax, total }`, each rounded to 2 decimals (half up).
> - **AC6**: A line with `quantity <= 0` or a negative `price` throws `InvalidLineError`.
>
> ## Tips
> - Keep each step (subtotal, discount, shipping, tax) in its own small function.
> - Round only at the end of each step, not inside the loop.
>
> Some extra tests for these criteria run when you ask for a review.

Starter: types and `calculateTotal` signature, error classes declared; the body
has only `// Write your solution here` and the minimal default return.

### Advanced (difficulty 9)

> ## Goal
> Build the pricing engine Cartly's checkout service calls to price an order.
>
> ## Acceptance criteria
> - **AC1**: `createPricingEngine(rules)` returns an object with `price(order): PriceBreakdown`.
> - **AC2**: Rules are applied in this order: line promotions → order discounts → shipping → tax. The breakdown lists each applied rule's id and amount.
> - **AC3**: At most one order-level discount applies: the one that gives the largest saving.
> - **AC4**: All money is handled in integer cents; `PriceBreakdown` amounts are integers. No floating-point money anywhere in the result.
> - **AC5**: Invalid orders throw `PricingError` with a `code` from: `EMPTY_ORDER`, `INVALID_QUANTITY`, `UNKNOWN_SKU`.
> - **AC6**: Pricing an order of 10,000 lines with 50 rules finishes in under 200 ms.
>
> ## Constraints
> - No external libraries.
> - Internal structure (files, classes, helpers) is your decision; tests only use `createPricingEngine` and the exported types.
>
> Additional tests for these criteria run when you ask for a review.

Starter: `src/index.ts` exporting the types and a `createPricingEngine` whose
body has only `// Write your solution here` and the minimal default return.
