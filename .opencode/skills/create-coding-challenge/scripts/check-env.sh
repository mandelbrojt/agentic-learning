#!/usr/bin/env bash
# Environment check for coding challenges.
#
# Usage: check-env.sh <language>
#   language: javascript | typescript | python | java | kotlin | go | rust |
#             ruby | csharp | php
#
# Loads version managers (see env.sh), then checks three layers:
#   1. version manager  2. runtime/toolchain  3. package manager / build tool
# Framework dependencies are NOT checked here: they are installed per project.
#
# Exit codes: 0 = ready, 1 = something missing, 2 = unsupported/unknown language.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/env.sh"

lang="$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')"
missing=0
warnings=0

ok()   { printf '  [OK]      %s\n' "$*"; }
miss() { printf '  [MISSING] %s\n' "$*"; missing=$((missing + 1)); }
warn() { printf '  [WARN]    %s\n' "$*"; warnings=$((warnings + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }

# Compare dotted versions: version_ge 3.12.1 3.10 -> true
version_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

detect_os() {
  local os pm distro=""
  os="$(uname -s)"
  case "$os" in
    Linux)
      if [ -r /etc/os-release ]; then
        # shellcheck source=/dev/null
        distro="$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-$ID}")"
      fi
      if grep -qi microsoft /proc/version 2>/dev/null; then
        os="Linux (WSL)"
      fi
      ;;
    Darwin) distro="macOS $(sw_vers -productVersion 2>/dev/null)" ;;
  esac
  pm="none detected"
  for p in apt-get dnf pacman zypper apk brew; do
    if have "$p"; then pm="$p"; break; fi
  done
  echo "System"
  echo "  OS:               $os ${distro:+- $distro}"
  echo "  Shell:            ${SHELL:-unknown}"
  echo "  System pkg mgr:   $pm"
  have curl && ok "curl available (needed by most installers)" || warn "curl not found (needed by most installers)"
  have git && ok "git available" || warn "git not found (some installers need it)"
  have jq && ok "jq available (needed for usage statistics)" || warn "jq not found (usage statistics will be skipped)"
}

check_node() {
  echo "Version manager"
  if have nvm; then
    ok "nvm $(nvm --version 2>/dev/null) ($NVM_DIR)"
  else
    miss "nvm not installed"
  fi
  echo "Runtime"
  if have node; then
    local v; v="$(node -v | sed 's/^v//')"
    case "$(command -v node)" in
      "$NVM_DIR"/*) ok "node $v (managed by nvm)" ;;
      *) warn "node $v found at $(command -v node), not managed by nvm" ;;
    esac
    if ! version_ge "$v" "20"; then
      miss "node $v is too old (need >= 20, current LTS recommended)"
    fi
  else
    if have nvm; then
      miss "no Node.js version installed through nvm (run: nvm install --lts)"
    else
      miss "node not installed"
    fi
  fi
  echo "Package manager"
  if have npm; then ok "npm $(npm -v 2>/dev/null)"; else miss "npm not available"; fi
  if have npx; then ok "npx available"; else miss "npx not available"; fi
  if [ "$lang" = "typescript" ]; then
    echo "  [INFO]    typescript, tsx and the test runner are installed per project (npm install)"
  fi
}

check_python() {
  echo "Version manager"
  if have pyenv; then
    ok "pyenv $(pyenv --version 2>/dev/null | awk '{print $2}') ($PYENV_ROOT)"
  else
    miss "pyenv not installed"
  fi
  echo "Runtime"
  local py=""
  if have pyenv; then
    local current; current="$(pyenv version-name 2>/dev/null)"
    if [ -z "$current" ] || [ "$current" = "system" ]; then
      miss "no pyenv-managed Python selected (run: pyenv install 3.12 && pyenv global 3.12)"
      local installed; installed="$(pyenv versions --bare 2>/dev/null | tr '\n' ' ')"
      [ -n "$installed" ] && echo "  [INFO]    pyenv versions installed: $installed"
    else
      py="$(pyenv which python 2>/dev/null)"
    fi
  fi
  if [ -z "$py" ] && have python3; then
    warn "only system Python available: $(command -v python3) ($(python3 -V 2>&1)); do not use it for challenges"
  fi
  if [ -n "$py" ]; then
    local v; v="$("$py" -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"
    ok "python $v ($py)"
    if ! version_ge "$v" "3.10"; then
      miss "python $v is too old (need >= 3.10, 3.12+ recommended)"
    elif ! version_ge "$v" "3.12"; then
      warn "python $v works, but 3.12+ is recommended"
    fi
    echo "Package manager"
    if "$py" -c 'import venv, ensurepip' >/dev/null 2>&1; then
      ok "venv + pip available"
    else
      miss "venv/ensurepip module missing in $py"
    fi
    echo "  [INFO]    pytest and frameworks are installed per project in .venv"
  fi
}

check_jvm() {
  echo "Version manager"
  if have sdk; then
    ok "SDKMAN! ($SDKMAN_DIR)"
  else
    miss "SDKMAN! not installed"
  fi
  echo "Runtime"
  if have java; then
    local v; v="$(java -version 2>&1 | head -n1 | sed -E 's/.*version "([^"]+)".*/\1/')"
    local major="${v%%.*}"
    case "$(command -v java)" in
      "$SDKMAN_DIR"/*) ok "java $v (managed by SDKMAN!)" ;;
      *) warn "java $v at $(command -v java), not managed by SDKMAN!" ;;
    esac
    if [ "${major:-0}" -lt 17 ] 2>/dev/null; then
      miss "java $v is too old (need >= 17, 21 LTS recommended)"
    fi
  else
    miss "java (JDK) not installed (run: sdk install java 21-tem)"
  fi
  echo "Build tool"
  local found=0
  if have gradle; then ok "gradle $(gradle --version 2>/dev/null | awk '/^Gradle/{print $2}')"; found=1; fi
  if have mvn; then ok "maven $(mvn -v 2>/dev/null | awk '/Apache Maven/{print $3}')"; found=1; fi
  [ $found -eq 0 ] && miss "neither gradle nor maven installed (run: sdk install gradle or sdk install maven)"
  if [ "$lang" = "kotlin" ]; then
    echo "  [INFO]    the Kotlin compiler is provided by the Gradle Kotlin plugin per project"
  fi
}

check_go() {
  echo "Version manager"
  if have goenv; then ok "goenv ($GOENV_ROOT)"; else echo "  [INFO]    goenv not installed (optional; official release is fine)"; fi
  echo "Runtime"
  if have go; then
    local v; v="$(go env GOVERSION 2>/dev/null | sed 's/^go//')"
    ok "go $v ($(command -v go))"
    if ! version_ge "$v" "1.22"; then
      miss "go $v is too old (need >= 1.22)"
    fi
  else
    miss "go not installed"
  fi
  echo "  [INFO]    modules and 'go test' are built in"
}

check_rust() {
  echo "Version manager"
  if have rustup; then ok "rustup $(rustup --version 2>/dev/null | awk '{print $2}')"; else miss "rustup not installed"; fi
  echo "Runtime"
  if have rustc; then ok "rustc $(rustc --version | awk '{print $2}')"; else miss "rustc not installed (run: rustup toolchain install stable)"; fi
  echo "Build tool"
  if have cargo; then ok "cargo $(cargo --version | awk '{print $2}')"; else miss "cargo not installed"; fi
}

check_ruby() {
  echo "Version manager"
  if have rbenv; then ok "rbenv $(rbenv --version | awk '{print $2}')"; else miss "rbenv not installed"; fi
  echo "Runtime"
  if have rbenv; then
    local current; current="$(rbenv version-name 2>/dev/null)"
    if [ -z "$current" ] || [ "$current" = "system" ]; then
      miss "no rbenv-managed Ruby selected (run: rbenv install <version> && rbenv global <version>)"
    fi
  fi
  if have ruby; then
    local v; v="$(ruby -e 'print RUBY_VERSION')"
    ok "ruby $v ($(command -v ruby))"
    version_ge "$v" "3.2" || miss "ruby $v is too old (need >= 3.2)"
  else
    miss "ruby not installed"
  fi
  echo "Package manager"
  if have bundle; then ok "bundler $(bundle -v | awk '{print $NF}')"; else miss "bundler not installed (run: gem install bundler)"; fi
}

check_dotnet() {
  echo "Runtime / SDK"
  if have dotnet; then
    local sdks; sdks="$(dotnet --list-sdks 2>/dev/null | awk '{print $1}' | tr '\n' ' ')"
    if [ -n "$sdks" ]; then
      ok ".NET SDKs: $sdks"
      local newest; newest="$(dotnet --list-sdks | awk '{print $1}' | sort -V | tail -n1)"
      version_ge "$newest" "8.0" || miss ".NET SDK $newest is too old (need >= 8.0 LTS)"
    else
      miss "dotnet found but no SDK installed"
    fi
  else
    miss ".NET SDK not installed"
  fi
  echo "  [INFO]    NuGet and 'dotnet test' are built in"
}

check_php() {
  echo "Runtime"
  if have php; then
    local v; v="$(php -r 'echo PHP_VERSION;')"
    ok "php $v ($(command -v php))"
    version_ge "$v" "8.2" || miss "php $v is too old (need >= 8.2)"
    for ext in mbstring xml dom; do
      php -m 2>/dev/null | grep -qix "$ext" || warn "php extension '$ext' not loaded (PHPUnit needs it)"
    done
  else
    miss "php not installed"
  fi
  echo "Package manager"
  if have composer; then ok "composer $(composer --version 2>/dev/null | awk '{print $3}')"; else miss "composer not installed"; fi
}

if [ -z "$lang" ]; then
  echo "Usage: check-env.sh <language>" >&2
  exit 2
fi

detect_os
echo
echo "Language: $lang"
case "$lang" in
  javascript|js|typescript|ts|node) [ "$lang" = "ts" ] && lang=typescript; check_node ;;
  python|py) check_python ;;
  java|kotlin|kt) [ "$lang" = "kt" ] && lang=kotlin; check_jvm ;;
  go|golang) check_go ;;
  rust|rs) check_rust ;;
  ruby|rb) check_ruby ;;
  csharp|c#|cs|dotnet|fsharp|f#) check_dotnet ;;
  php) check_php ;;
  *)
    echo "  [UNKNOWN] no automatic check for '$lang'."
    echo "            Check manually using references/toolchains.md (\"Other languages\")."
    exit 2
    ;;
esac

echo
if [ "$missing" -eq 0 ]; then
  echo "RESULT: READY ($warnings warning(s))"
  exit 0
else
  echo "RESULT: NOT READY ($missing missing, $warnings warning(s))"
  exit 1
fi
