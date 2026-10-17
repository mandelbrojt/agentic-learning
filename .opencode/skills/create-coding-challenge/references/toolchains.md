# Toolchains: detection, installation and loading

Use this when `scripts/check-env.sh` reports `NOT READY`, or for a language it
does not cover. Always prefer the **recommended version manager**: it installs
runtimes in the user's home directory, needs no `sudo` for runtime installs, and
lets each challenge pin its own version.

## Who runs what

Every install step is tagged:

- **[agent]**: user-level, runs in `$HOME`, no `sudo`, does not edit shell rc
  files. The agent may run it **only after the user explicitly confirms**.
- **[user]**: needs `sudo`, edits `~/.zshrc` / `~/.bashrc` / `~/.profile`, or
  pipes a remote installer that modifies shell startup files. **Never run these.**
  Show the exact commands and ask the user to run them in their own terminal,
  then re-run the check.

Rules:

1. Use the OS-specific commands that match the `System` section of the check.
2. Use the user's login shell (`$SHELL`) to pick the rc file: zsh → `~/.zshrc`,
   bash → `~/.bashrc`, macOS bash → `~/.bash_profile`.
3. After a **[user]** step, ask the user to open a new terminal (or `source` the
   rc file) and tell you when it is done. Then re-run `check-env.sh`.
4. Agent shells do not read rc files. Always run language commands as
   `. "<skill-dir>/scripts/env.sh" && <command>`.
5. Long installs (for example `pyenv install`, which compiles Python) can take
   several minutes: use a long shell timeout (≥ 15 minutes).
6. If an installer URL or version number seems outdated, check the official
   project page (linked below) before giving instructions.

---

## JavaScript / TypeScript: nvm + Node.js LTS

Official: <https://github.com/nvm-sh/nvm>

| Layer | Tool |
|---|---|
| Version manager | nvm |
| Runtime | Node.js current LTS (minimum 20) |
| Package manager | npm (bundled). pnpm/yarn via `corepack enable` only if the user asks |
| Version pin file | `.nvmrc` (for example `24`) |

Install:

1. **[user]** Install nvm (its installer edits the rc file):
   ```sh
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
   ```
   (Check the README for the latest tag.) Then open a new terminal.
2. **[agent]** Install and select Node LTS:
   ```sh
   . "<skill-dir>/scripts/env.sh" && nvm install --lts && nvm alias default 'lts/*'
   ```
3. Verify: `node -v && npm -v`

If Node exists but is not managed by nvm (for example installed with `apt`),
warn the user and recommend installing it through nvm. Continue only if its
version is ≥ 20.

---

## Python: pyenv + venv/pip

Official: <https://github.com/pyenv/pyenv>

| Layer | Tool |
|---|---|
| Version manager | pyenv |
| Runtime | CPython 3.12+ (minimum 3.10) |
| Package manager | per-project `.venv` created with `python -m venv`, then `pip` |
| Version pin file | `.python-version` (for example `3.12`) |

Never use the system Python (`/usr/bin/python3`) for a challenge: it is owned
by the OS, often lacks `ensurepip`, and is blocked by PEP 668 for pip installs.

Install:

1. **[user]** Build dependencies (needed to compile Python):
   - Ubuntu/Debian:
     ```sh
     sudo apt update && sudo apt install -y make build-essential libssl-dev zlib1g-dev \
       libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils \
       tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
     ```
   - Fedora: `sudo dnf install -y make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2`
   - Arch: `sudo pacman -S --needed base-devel openssl zlib xz tk`
   - macOS: `xcode-select --install && brew install openssl readline sqlite3 xz zlib tcl-tk`
2. **[user]** Install pyenv:
   - Linux: `curl -fsSL https://pyenv.run | bash`
   - macOS: `brew install pyenv`
3. **[user]** Add to the rc file (zsh shown; same lines for bash in `~/.bashrc`):
   ```sh
   export PYENV_ROOT="$HOME/.pyenv"
   [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
   eval "$(pyenv init - zsh)"
   ```
   Then open a new terminal.
4. **[agent]** Install and select Python (takes a few minutes):
   ```sh
   . "<skill-dir>/scripts/env.sh" && pyenv install 3.12 && pyenv global 3.12
   ```
5. Verify: `pyenv version && python -V && python -c "import venv, ensurepip"`

Alternative (only if the user prefers it): `uv` can manage both interpreters
and packages. Keep pyenv as the default recommendation.

---

## Java / Kotlin: SDKMAN!

Official: <https://sdkman.io>

| Layer | Tool |
|---|---|
| Version manager | SDKMAN! |
| Runtime | Temurin JDK 21 LTS (minimum 17) |
| Build tool | Gradle (default; Kotlin DSL) or Maven |
| Version pin file | `.sdkmanrc` (for example `java=21.0.5-tem`) |

Install:

1. **[user]** Prerequisites on Linux: `sudo apt install -y zip unzip curl` (or the dnf/pacman equivalent).
2. **[user]** Install SDKMAN! (edits rc files):
   ```sh
   curl -s "https://get.sdkman.io" | bash
   ```
   Then open a new terminal.
3. **[agent]**:
   ```sh
   . "<skill-dir>/scripts/env.sh" && sdk install java 21-tem && sdk install gradle
   ```
   Use `sdk list java` if `21-tem` is not resolvable. Add `sdk install maven` if the challenge uses Maven.
4. Verify: `java -version && gradle --version`

Kotlin needs no separate compiler: the Gradle `kotlin("jvm")` plugin provides it.

---

## Go: official release (goenv optional)

Official: <https://go.dev/doc/install>

| Layer | Tool |
|---|---|
| Version manager | none required; `goenv` if the user wants multiple versions |
| Runtime | latest stable Go (minimum 1.22) |
| Package manager / tests | Go modules + `go test` (built in) |
| Version pin | `go` directive in `go.mod` |

Install:

- Linux **[user]** (needs `sudo` for `/usr/local`):
  ```sh
  curl -LO https://go.dev/dl/go1.25.0.linux-amd64.tar.gz   # check go.dev/dl for the latest file and the right architecture
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
  echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"' >> ~/.zshrc
  ```
- macOS **[user]**: `brew install go`
- Optional goenv **[user]**: `git clone https://github.com/go-nv/goenv.git ~/.goenv`, then add
  `export GOENV_ROOT="$HOME/.goenv"; export PATH="$GOENV_ROOT/bin:$PATH"; eval "$(goenv init -)"` to the rc file;
  **[agent]** `goenv install <version> && goenv global <version>`.
- Verify: `go version`

Avoid the distro `golang` package: it is often several versions behind.

---

## Rust: rustup

Official: <https://rustup.rs>

| Layer | Tool |
|---|---|
| Version manager | rustup |
| Runtime | stable toolchain |
| Build / tests | cargo + `cargo test` |
| Version pin file | `rust-toolchain.toml` (`[toolchain] channel = "stable"`) |

Install:

1. **[user]** Linux: `sudo apt install -y build-essential` (a C linker is required).
2. **[user]** `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh` (edits shell profile files). Open a new terminal.
3. **[agent]** `. "<skill-dir>/scripts/env.sh" && rustup toolchain install stable && rustup default stable`
4. Verify: `rustc --version && cargo --version`

---

## Ruby: rbenv + ruby-build

Official: <https://github.com/rbenv/rbenv>

| Layer | Tool |
|---|---|
| Version manager | rbenv + ruby-build plugin |
| Runtime | latest stable Ruby (minimum 3.2) |
| Package manager | Bundler |
| Version pin file | `.ruby-version` |

Install:

1. **[user]** Build deps (Ubuntu): `sudo apt install -y autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev`
2. **[user]** Linux: `git clone https://github.com/rbenv/rbenv.git ~/.rbenv && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build`
   then add `eval "$(~/.rbenv/bin/rbenv init - zsh)"` to `~/.zshrc`. macOS: `brew install rbenv ruby-build` + the same init line.
3. **[agent]** `. "<skill-dir>/scripts/env.sh" && rbenv install -l` (pick the latest stable) then
   `rbenv install <version> && rbenv global <version> && gem install bundler`
4. Verify: `ruby -v && bundle -v`

---

## C# / .NET: dotnet-install script

Official: <https://learn.microsoft.com/dotnet/core/install/linux-scripted-manual>

| Layer | Tool |
|---|---|
| Version manager | `dotnet-install.sh` (user-level, side-by-side SDKs) |
| Runtime | .NET LTS SDK (minimum 8.0) |
| Package manager / tests | NuGet + `dotnet test` (built in) |
| Version pin file | `global.json` |

Install:

1. **[agent]** User-level install into `~/.dotnet` (no sudo, no rc edits):
   ```sh
   mkdir -p /tmp/opencode
   curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/opencode/dotnet-install.sh
   bash /tmp/opencode/dotnet-install.sh --channel LTS
   ```
2. **[user]** Make it permanent in the rc file:
   `export DOTNET_ROOT="$HOME/.dotnet"; export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"`
3. Alternatives **[user]**: Ubuntu `sudo apt install -y dotnet-sdk-8.0`; macOS `brew install --cask dotnet-sdk`.
4. Verify: `dotnet --list-sdks`

---

## PHP: system packages + Composer

Official: <https://getcomposer.org/download/>

| Layer | Tool |
|---|---|
| Version manager | none standard; distro packages, `ppa:ondrej/php` (Ubuntu) or Homebrew |
| Runtime | PHP 8.2+ with `mbstring`, `xml`, `dom` |
| Package manager | Composer |

Install:

1. **[user]** Ubuntu: `sudo apt install -y php-cli php-mbstring php-xml php-curl unzip`. macOS: `brew install php`.
2. **[agent]** Composer, user-level:
   ```sh
   mkdir -p ~/.local/bin /tmp/opencode
   php -r "copy('https://getcomposer.org/installer', '/tmp/opencode/composer-setup.php');"
   php /tmp/opencode/composer-setup.php --install-dir="$HOME/.local/bin" --filename=composer
   ```
   (macOS: **[user]** `brew install composer`.)
3. Verify: `php -v && composer --version`

---

## Other languages

`check-env.sh` exits with code 2 for languages it does not know. Check manually
with the same three layers, using these recommended managers:

| Language | Version manager | Package / test tooling |
|---|---|---|
| Elixir / Erlang | `asdf` or `mise` | Mix + ExUnit |
| Dart / Flutter | `fvm` | pub + `dart test` / `flutter test` |
| Swift | `swiftly` (Linux) / Xcode (macOS) | SwiftPM + XCTest / Swift Testing |
| Scala | Coursier (`cs setup`) | sbt + MUnit / ScalaTest |
| C / C++ | system compiler (`build-essential`, Xcode CLT) | CMake + GoogleTest / Catch2 |
| Lua | `luaver` / system | LuaRocks + busted |
| Deno / Bun (JS runtimes) | official installers | built-in test runners |

Follow the same rules: find detection commands, mark each step [agent] or [user],
pin the version in the challenge, and load the manager explicitly before each
command.
