#!/usr/bin/env bash
#
# test.sh - verify the dotfiles tree.
#
# Runs install.sh against a throwaway $HOME, so your real home directory is
# never touched. Safe to run at any time.
#
#   ./test.sh
#
# Exit status is the number of failed checks.

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_HOME="$HOME"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT

pass=0
fail=0
skipped=0

ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; pass=$((pass+1)); }
no()   { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; [ -n "${2:-}" ] && printf '        %s\n' "$2"; fail=$((fail+1)); }
skip() { printf '  \033[2mSKIP  %s (%s)\033[0m\n' "$1" "$2"; skipped=$((skipped+1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# check <name> <command...>
check() {
  local name="$1"; shift
  local out
  if out=$("$@" 2>&1); then ok "$name"; else no "$name" "${out%%$'\n'*}"; fi
}

# ---------------------------------------------------------------- syntax ----
head_ "Shell syntax"

for f in "$DOTFILES"/home/.bash* "$DOTFILES"/home/.profile "$DOTFILES"/home/.xprofile \
         "$DOTFILES"/install.sh "$DOTFILES"/config/polybar/scripts/battery.sh; do
  [ -f "$f" ] || continue
  check "${f#$DOTFILES/}" bash -n "$f"
done

if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck install.sh" shellcheck -S error "$DOTFILES/install.sh"
else
  skip "shellcheck" "not installed"
fi

# ------------------------------------------------------------- dry run ------
head_ "install.sh --dry-run changes nothing"

mkdir -p "$SANDBOX/dry"
printf 'sentinel\n' > "$SANDBOX/dry/.bashrc"
before="$(md5sum "$SANDBOX/dry/.bashrc" | cut -d' ' -f1)"
( HOME="$SANDBOX/dry" XDG_CONFIG_HOME= "$DOTFILES/install.sh" --dry-run ) >/dev/null 2>&1
after="$(md5sum "$SANDBOX/dry/.bashrc" | cut -d' ' -f1)"

if [ "$before" = "$after" ]; then ok "pre-existing file untouched"
else no "pre-existing file untouched" "dry run modified .bashrc"; fi

if [ -z "$(find "$SANDBOX/dry" -type l)" ]; then ok "no symlinks created"
else no "no symlinks created" "dry run created links"; fi

# --------------------------------------------------------------- install ----
head_ "install.sh into a sandbox HOME"

mkdir -p "$SANDBOX/home"
if out=$( HOME="$SANDBOX/home" XDG_CONFIG_HOME= "$DOTFILES/install.sh" --force 2>&1 ); then
  ok "install.sh exits 0"
else
  no "install.sh exits 0" "${out##*$'\n'}"
fi

for f in .bashrc .bash_aliases .bash_functions .bash_path .bash_prompt \
         .profile .xprofile .gitconfig .tmux.conf .vimrc .Xresources; do
  target="$SANDBOX/home/$f"
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$DOTFILES/home/$f" ]; then
    ok "~/$f -> home/$f"
  else
    no "~/$f -> home/$f" "not a symlink into the repo"
  fi
done

for d in nvim i3 polybar picom lf kitty git; do
  target="$SANDBOX/home/.config/$d"
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$DOTFILES/config/$d" ]; then
    ok "~/.config/$d -> config/$d"
  else
    no "~/.config/$d -> config/$d" "not a symlink into the repo"
  fi
done

# ----------------------------------------------------------- idempotency ----
head_ "Rerunning install.sh is a no-op"

out=$( HOME="$SANDBOX/home" XDG_CONFIG_HOME= "$DOTFILES/install.sh" --force 2>&1 )
if printf '%s' "$out" | grep -q "already linked"; then
  ok "reports existing links as already linked"
else
  no "reports existing links as already linked"
fi

if [ ! -d "$SANDBOX/home/.dotfiles-backup" ]; then
  ok "no backup created on second run"
else
  no "no backup created on second run" "backup dir appeared"
fi

# ------------------------------------------------------------ live shell ----
head_ "Interactive shell loads cleanly"

# Ubuntu's /etc/bash.bashrc prints a sudo hint until this marker exists.
# A real home has it; create it so we only see output our own config causes.
touch "$SANDBOX/home/.sudo_as_admin_successful"

# Interactive bash without a controlling tty always emits a job-control
# notice; that is an artifact of the test, not of the config.
shell_err=$( HOME="$SANDBOX/home" bash -ic 'true' 2>&1 </dev/null \
             | grep -v 'cannot set terminal process group' \
             | grep -v 'no job control in this shell' )
if [ -z "$shell_err" ]; then
  ok "startup produces no errors or warnings"
else
  no "startup produces no errors or warnings" "${shell_err%%$'\n'*}"
fi

probe() {
  HOME="$SANDBOX/home" bash -ic "$1" </dev/null >/dev/null 2>&1
}

for fn in gtc gtp gtn gtm asl ovd mklambda c mkfile capture; do
  if probe "declare -F $fn"; then ok "function $fn defined"; else no "function $fn defined"; fi
done

for al in ll lt l sapt tocb npr npt tvim; do
  if probe "alias $al"; then ok "alias $al defined"; else no "alias $al defined"; fi
done

if probe '[[ $- == *i* ]] && set -o | grep -q "^vi.*on"'; then
  ok "readline vi mode enabled"
else
  no "readline vi mode enabled"
fi

if probe 'case ":$PATH:" in *":$HOME/.local/bin:"*) exit 0;; *) exit 1;; esac'; then
  ok "PATH contains ~/.local/bin"
else
  no "PATH contains ~/.local/bin"
fi

if probe 'case ":$PATH:" in *"/usr/local/go/bin"*) exit 0;; *) exit 1;; esac'; then
  ok "PATH contains Go toolchain"
else
  no "PATH contains Go toolchain"
fi

# --------------------------------------------------- work/public split ------
head_ "Public/private split"

names() {
  grep -hoE "^[[:space:]]*(alias[[:space:]]+[A-Za-z0-9_-]+|[A-Za-z0-9_-]+[[:space:]]*\(\))" "$@" 2>/dev/null \
    | sed 's/^[[:space:]]*//; s/alias //; s/[[:space:]]*()//' | sort -u
}

if [ -f "$REAL_HOME/.bash_work" ]; then
  orig="$SANDBOX/orig.txt"; new="$SANDBOX/new.txt"
  git -C "$DOTFILES" show master:ubuntu/.bash_aliases 2>/dev/null > "$SANDBOX/old_aliases" || true
  names "$DOTFILES"/home/.bash_aliases "$DOTFILES"/home/.bash_functions "$REAL_HOME/.bash_work" > "$new"

  missing=""
  for n in $(names "$REAL_HOME/.bash_work"); do
    grep -qx "$n" "$new" || missing="$missing $n"
  done
  if [ -z "$missing" ]; then ok "every ~/.bash_work name resolves"
  else no "every ~/.bash_work name resolves" "missing:$missing"; fi

  # .bash_work must be sourced last so its overrides win
  if grep -q 'bash_work' "$DOTFILES/home/.bashrc" && \
     [ "$(grep -n 'bash_work\|bash_functions' "$DOTFILES/home/.bashrc" | tail -1 | grep -c bash_work)" -eq 1 ]; then
    ok ".bash_work sourced after .bash_functions"
  else
    no ".bash_work sourced after .bash_functions"
  fi
else
  skip "work split checks" "~/.bash_work not present"
fi

if ! git -C "$DOTFILES" check-ignore -q home/.bash_work 2>/dev/null; then
  no ".bash_work is gitignored"
else
  ok ".bash_work is gitignored"
fi

# ------------------------------------------------------------- secrets ------
head_ "No private content in the tracked tree"

pattern='tactacam|tattatok|tactatok|scout-aws|scout-types|pet-backend|clood|libreboot|192\.168\.|10\.[0-9]+\.[0-9]+\.[0-9]+|/var/www|\.pem\b|config\.ovpn|BEGIN (PGP|RSA|OPENSSH) |AKIA[0-9A-Z]{16}'
hits=$(grep -rniE "$pattern" "$DOTFILES" \
        --exclude-dir=.git --exclude=test.sh --exclude=README.md \
        --exclude-dir=hosts 2>/dev/null | head -5)
if [ -z "$hits" ]; then ok "no employer paths, hosts, or keys"
else no "no employer paths, hosts, or keys" "$(printf '%s' "$hits" | head -1)"; fi

if grep -rq "$REAL_HOME" "$DOTFILES/config" "$DOTFILES/home" 2>/dev/null; then
  no "no hardcoded home paths" "$(grep -rl "$REAL_HOME" "$DOTFILES/config" "$DOTFILES/home" | head -1)"
else
  ok "no hardcoded home paths"
fi

# --------------------------------------------------------- app configs ------
head_ "Application configs parse"

if command -v nvim >/dev/null 2>&1; then
  # Uses the real plugin dir; only checks that init.lua evaluates without error.
  #
  # nvim-lspconfig v2 emits a deprecation notice on every startup because this
  # machine is on Neovim 0.10.x. It is expected and documented in init.lua, so
  # it is filtered here -- any other output still fails the check.
  out=$(timeout 60 nvim --headless -u "$DOTFILES/config/nvim/init.lua" -c 'qa' 2>&1 \
        | grep -vF 'nvim-lspconfig support for Nvim 0.10 or older is deprecated' \
        | grep -vF 'Feature will be removed in nvim-lspconfig v3.0.0')
  if [ -z "$out" ]; then
    ok "nvim init.lua loads without errors"
  else
    no "nvim init.lua loads without errors" "${out%%$'\n'*}"
  fi
else
  skip "nvim" "not installed"
fi

if command -v i3 >/dev/null 2>&1; then
  check "i3 config validates" i3 -C -c "$DOTFILES/config/i3/config"
else
  skip "i3" "not installed"
fi

if command -v polybar >/dev/null 2>&1; then
  check "polybar config parses" polybar --config="$DOTFILES/config/polybar/config.ini" --dump=width
else
  skip "polybar" "not installed"
fi

if command -v picom >/dev/null 2>&1; then
  check "picom config parses" picom --config "$DOTFILES/config/picom/picom.conf" --diagnostics
else
  skip "picom" "not installed"
fi

if [ -x "$DOTFILES/config/polybar/scripts/battery.sh" ]; then
  ok "polybar battery.sh is executable"
else
  no "polybar battery.sh is executable" "chmod +x it, polybar will not run it otherwise"
fi

# -------------------------------------------------------------- packages ----
head_ "Package lists"

for f in apt.txt npm-global.txt go-tools.txt; do
  if [ -s "$DOTFILES/packages/$f" ]; then
    ok "packages/$f is non-empty ($(grep -cv '^#' "$DOTFILES/packages/$f") entries)"
  else
    no "packages/$f is non-empty"
  fi
done

if [ -s "$DOTFILES/packages/manual.md" ]; then ok "packages/manual.md present"
else no "packages/manual.md present"; fi

# ---------------------------------------------------------------- result ----
printf '\n\033[1m%d passed, %d failed' "$pass" "$fail"
[ "$skipped" -gt 0 ] && printf ', %d skipped' "$skipped"
printf '\033[0m\n\n'

exit "$fail"
