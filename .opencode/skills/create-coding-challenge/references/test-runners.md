# Test runners and project setup by ecosystem

Always use the **standard test runner of the ecosystem** (or the framework's
default). Never write a custom test harness.

Every challenge must:

- Run all visible tests with **one command**, recorded as `testCommand` in
  `.challenge/meta.json` and shown in `assignment.md`.
- Install dependencies with **one command** (`setupCommand`), project-local only
  (`node_modules`, `.venv`, `vendor`, build dirs). Never install globally.
- Be self-contained: **no network calls, external services, databases, Docker
  or API keys** while testing. Use in-memory fakes, fixtures, SQLite in memory,
  `httptest`/`supertest`/test clients, or injected dependencies.
- Pin the toolchain version (`.nvmrc`, `.python-version`, `go.mod`,
  `.sdkmanrc`, `rust-toolchain.toml`, `.ruby-version`, `global.json`).
- Ship a `.gitignore` for dependency and build folders.
- Mark where the learner writes code with a single `Write your solution here`
  comment, **only** in the entry-point files the learner edits. Place it where
  the solution belongs (function or method body, class, component, route
  handler, end of a module...). No other TODO or step comments, and no thrown
  "not implemented" errors.
- The starter must still **compile/import** so tests run and fail on their
  assertions instead of a build error. When a body can't be empty (a declared
  return type, a required return value), add only the smallest default value
  after the comment. Otherwise the comment stands alone.

| Language | Comment | Minimal default return (only if needed to compile) |
|---|---|---|
| TypeScript / JavaScript | `// Write your solution here` (in JSX: `{/* Write your solution here */}`) | JS: none. TS: `return 0;`, `return "";`, `return [];`, `return null;`, or `return {} as T;` to match the type |
| Python | `# Write your solution here` | `pass` (empty bodies are a syntax error) |
| Java | `// Write your solution here` | `return 0;`, `return null;`, `return false;`... |
| Kotlin | `// Write your solution here` | `return 0`, `return ""`, `return emptyList()`... |
| Go | `// Write your solution here` | `return 0`, `return ""`, `return nil`, `return T{}`... |
| Rust | `// Write your solution here` | `Default::default()` or a literal (`0`, `String::new()`, `Vec::new()`) |
| Ruby | `# Write your solution here` | none |
| C# | `// Write your solution here` | `return default;` |
| PHP | `// Write your solution here` | `return 0;`, `return '';`, `return [];`... (only with a declared return type) |

Example (TypeScript):

```ts
export function calculateTotal(items: CartItem[]): number {
  // Write your solution here
  return 0;
}
```

Test naming: prefix every test name with the criterion ID, for example
`"AC2: joins chat messages with a newline"`. Group tests per function or
feature. One behavior per test at beginner level.

Check the latest stable major versions of libraries (npm/pypi/maven/crates
registries or official docs) when unsure. Prefer the official scaffolding tool
for heavy frameworks, then **trim** everything the challenge does not need.

---

## JavaScript / TypeScript (Node via nvm)

Default runner: **Vitest** (native TypeScript and ESM, no config needed).

Minimal layout:
```
package.json        "type": "module", scripts: { "test": "vitest run" }
tsconfig.json       see below
.nvmrc
src/<module>.ts
tests/<module>.test.ts
```
- Dev deps: `vitest`, `typescript`, `@types/node` (TS only). Plain JS: only `vitest`.
- Verified `tsconfig.json` for Node projects (`skipLibCheck` and `@types/node`
  are required, otherwise `tsc` fails on Vitest's own type declarations):
  ```json
  {
    "compilerOptions": {
      "strict": true,
      "target": "ES2022",
      "module": "NodeNext",
      "moduleResolution": "NodeNext",
      "types": ["node"],
      "skipLibCheck": true,
      "noEmit": true
    },
    "include": ["src", "tests"]
  }
  ```
  With `NodeNext`, relative imports in tests use the `.js` extension:
  `import { calculateTotal } from "../src/cart.js";`
- Don't enable `noUnusedParameters`/`noUnusedLocals`: starter functions have unused parameters.
- `setupCommand`: `npm install` · `testCommand`: `npm test`
- Type-check in verification with `npx tsc --noEmit` so the starter compiles.

Frameworks:

| Framework | Setup | Testing approach |
|---|---|---|
| Node HTTP / Express / Fastify | export the `app` without calling `listen()` | `supertest` (Express) or `app.inject()` (Fastify) |
| React | Vite React-TS layout, trimmed | Vitest + `@testing-library/react` + `@testing-library/user-event` + `jsdom` (`test.environment: "jsdom"` in `vite.config.ts`) |
| Vue | Vite Vue-TS layout, trimmed | Vitest + `@vue/test-utils` + `jsdom` |
| Svelte | Vite Svelte-TS layout | Vitest + `@testing-library/svelte` + `jsdom` |
| Next.js | minimal app; test pure modules, route handlers and components | Vitest + Testing Library for components; call route handler functions directly with `Request` objects |
| NestJS | `@nestjs/cli` layout, trimmed | Jest (Nest default) + `@nestjs/testing`; `testCommand`: `npm test` |
| Angular | Angular CLI layout, trimmed | the current Angular CLI default runner (`ng test`); check the Angular docs for the current default |

## Python (pyenv + venv)

Default runner: **pytest**.

Minimal layout:
```
pyproject.toml      [project] metadata + [tool.pytest.ini_options] pythonpath = ["src"], testpaths = ["tests"]
requirements-dev.txt  (or [project.optional-dependencies] dev = [...])
.python-version
src/<package>/__init__.py
src/<package>/<module>.py
tests/test_<module>.py
```
- `setupCommand`: `python -m venv .venv && .venv/bin/pip install -r requirements-dev.txt`
- `testCommand`: `.venv/bin/python -m pytest`
- Use type hints in starter signatures; dataclasses or `TypedDict` for records.

Frameworks:

| Framework | Testing approach |
|---|---|
| Flask | app factory `create_app()`; `app.test_client()` in a pytest fixture |
| FastAPI | `fastapi.testclient.TestClient` (needs `httpx`); dependency overrides for fakes |
| Django | `pytest-django` with `DJANGO_SETTINGS_MODULE`, SQLite in-memory; or `python manage.py test` |
| pandas / data | pytest with small inline DataFrames; `pandas.testing.assert_frame_equal` |

## Java (SDKMAN!)

Default runner: **JUnit 5 (Jupiter)** with **Gradle** (Kotlin DSL) unless the user prefers Maven.

Layout:
```
settings.gradle.kts, build.gradle.kts   (java toolchain 21, junit-jupiter, tasks.test { useJUnitPlatform() })
.sdkmanrc
src/main/java/<pkg>/...
src/test/java/<pkg>/...Test.java
```
- Generate a wrapper during creation (`gradle wrapper`) so learners run `./gradlew test`.
- `testCommand`: `./gradlew test` (Maven: `mvn -q test`)
- Spring Boot: `spring-boot-starter-test`, `@WebMvcTest` + `MockMvc` or `@SpringBootTest` with in-memory H2. Generate the base with start.spring.io settings, then trim.

## Kotlin (SDKMAN!)

Gradle Kotlin DSL with `kotlin("jvm")`, JUnit 5 (`kotlin("test")` + `useJUnitPlatform()`).
Ktor: `testApplication { }` from `ktor-server-test-host`.

## Go

Default runner: **`go test`** (standard `testing` package), table-driven tests.

Layout:
```
go.mod              module <name>; go 1.2x
<pkg>.go
<pkg>_test.go       package <pkg> (or <pkg>_test for black-box tests)
```
- `setupCommand`: `go mod download` (or none) · `testCommand`: `go test ./...`
- HTTP (net/http, Gin, Echo, Chi): `net/http/httptest` with `httptest.NewRecorder()`.
- Avoid third-party assertion libs unless the user asks; `t.Errorf` with clear got/want messages.

## Rust

Default runner: **`cargo test`**.

Layout: library crate (`src/lib.rs`), integration tests in `tests/<feature>.rs`, `rust-toolchain.toml`.
- `testCommand`: `cargo test`
- Axum: build the `Router` in a function; test with `tower::ServiceExt::oneshot`.
- Starters use `// Write your solution here` plus `Default::default()` (or a literal) when a return value is needed; mark unused params with `_` prefix to avoid warnings.

## Ruby

Default runner: **RSpec** (plain Ruby) or **Minitest** (Rails default).

Layout: `Gemfile` (`rspec`), `.ruby-version`, `lib/<name>.rb`, `spec/<name>_spec.rb`, `.rspec` (`--require spec_helper`).
- `setupCommand`: `bundle install` · `testCommand`: `bundle exec rspec`
- Rails: keep the default Minitest; `bin/rails test`. Sinatra: `rack-test`.

## C# / .NET

Default runner: **xUnit** via `dotnet test`.

Layout:
```
<Name>.sln
src/<Name>/<Name>.csproj
tests/<Name>.Tests/<Name>.Tests.csproj   (references src project)
global.json
```
- Create with `dotnet new sln`, `dotnet new classlib`, `dotnet new xunit`, `dotnet sln add`, `dotnet add reference`.
- `testCommand`: `dotnet test`
- ASP.NET Core: `Microsoft.AspNetCore.Mvc.Testing` + `WebApplicationFactory<Program>`.

## PHP

Default runner: **PHPUnit** (or Pest for Laravel if the user asks).

Layout: `composer.json` (PSR-4 autoload `src/`, dev dep `phpunit/phpunit`), `phpunit.xml`, `src/`, `tests/`.
- `setupCommand`: `composer install` · `testCommand`: `vendor/bin/phpunit`
- Laravel: `php artisan test` with SQLite in-memory.

---

## Running extra tests in a temporary copy

Used in two places:

- **create-coding-challenge, verification step**: run tests against a throwaway
  reference solution.
- **review-coding-challenge**: run hidden tests generated at review time.

The challenge folder itself must never receive solution code or hidden tests.

Procedure:

1. Create a work dir: `WORK=$(mktemp -d /tmp/opencode/challenge-XXXXXX)`
   (run `mkdir -p /tmp/opencode` first).
2. Copy the project **without dependency/build folders**:
   `rsync -a --exclude node_modules --exclude .venv --exclude target --exclude build --exclude .gradle --exclude bin --exclude obj --exclude vendor <challenge>/ "$WORK"/`
   (If `rsync` is missing, use `cp -r` and delete those folders.)
3. Reuse dependencies instead of reinstalling:
   - Node: `ln -s <challenge>/node_modules "$WORK"/node_modules`
   - Python: use the original interpreter, `<challenge>/.venv/bin/python -m pytest` from `$WORK`
   - PHP: `ln -s <challenge>/vendor "$WORK"/vendor`
   - Go, Rust, JVM, .NET, Ruby: shared caches make a rebuild cheap; just run the command.
4. Add the extra files, following the runner's discovery rules:

| Ecosystem | Hidden/extra test location |
|---|---|
| Vitest/Jest | `tests/hidden.test.ts` |
| pytest | `tests/test_hidden.py` |
| JUnit | `src/test/java/<pkg>/HiddenTest.java` |
| go test | `<pkg>/hidden_test.go` (same package as visible tests) |
| cargo | `tests/hidden.rs` |
| RSpec / Minitest | `spec/hidden_spec.rb` / `test/hidden_test.rb` |
| xUnit | `tests/<Name>.Tests/HiddenTests.cs` |
| PHPUnit | `tests/HiddenTest.php` |

5. Run with `. "<skill-dir>/scripts/env.sh" && cd "$WORK" && <testCommand>` (or run only the hidden file).
6. Delete the work dir when finished: `rm -rf "$WORK"`.
