# Loads user-level version managers into the current shell.
#
# Agent shells are non-interactive and do not read ~/.zshrc or ~/.bashrc, so
# tools such as nvm, pyenv, rbenv, SDKMAN!, rustup and goenv are invisible
# unless loaded explicitly. Source this file before any language command:
#
#   . "<skill-dir>/scripts/env.sh" && npm test
#
# Compatible with bash and zsh. Safe to source multiple times. Never fails.

if [ -n "${ZSH_VERSION:-}" ]; then
  _cc_shell=zsh
else
  _cc_shell=bash
fi

_cc_prepend_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}

# Homebrew (macOS and Linuxbrew)
for _cc_brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [ -x "$_cc_brew" ]; then
    eval "$("$_cc_brew" shellenv)" 2>/dev/null
    break
  fi
done

_cc_prepend_path "$HOME/.local/bin"

# nvm (Node.js)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh" --no-use >/dev/null 2>&1
  if [ -f ".nvmrc" ]; then
    nvm use >/dev/null 2>&1 || nvm use default >/dev/null 2>&1
  else
    nvm use default >/dev/null 2>&1
  fi
fi

# pyenv (Python)
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
_cc_prepend_path "$PYENV_ROOT/bin"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - "$_cc_shell" 2>/dev/null || pyenv init - 2>/dev/null)"
fi

# rbenv (Ruby)
_cc_prepend_path "$HOME/.rbenv/bin"
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - "$_cc_shell" 2>/dev/null)"
fi

# goenv (Go) and the official Go install location
export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
_cc_prepend_path "$GOENV_ROOT/bin"
if command -v goenv >/dev/null 2>&1; then
  eval "$(goenv init - 2>/dev/null)"
fi
_cc_prepend_path "/usr/local/go/bin"
_cc_prepend_path "$HOME/go/bin"

# rustup / cargo (Rust)
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# SDKMAN! (Java, Kotlin, Gradle, Maven)
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  . "$SDKMAN_DIR/bin/sdkman-init.sh" >/dev/null 2>&1
fi

# .NET (dotnet-install script location)
if [ -d "$HOME/.dotnet" ]; then
  export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
  _cc_prepend_path "$HOME/.dotnet"
  _cc_prepend_path "$HOME/.dotnet/tools"
fi

# Composer global bin (PHP)
_cc_prepend_path "$HOME/.config/composer/vendor/bin"
_cc_prepend_path "$HOME/.composer/vendor/bin"

export PATH
unset _cc_brew _cc_shell
unset -f _cc_prepend_path 2>/dev/null
true
