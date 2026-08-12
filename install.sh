#!/usr/bin/env bash
#
# install.sh - symlink the tracked dotfiles into place.
#
# Idempotent: rerunning it is a no-op for links that already point here.
# Anything it would overwrite is backed up first.
#
#   ./install.sh            # link everything
#   ./install.sh --dry-run  # show what would happen, change nothing
#   ./install.sh --force    # replace existing files without prompting
#
# Does NOT install packages. See packages/ for those.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

info()  { printf '  %s\n' "$*"; }
skip()  { printf '  \033[2m%-28s already linked\033[0m\n' "$1"; }
link()  { printf '  \033[32m%-28s -> %s\033[0m\n' "$1" "$2"; }
warn()  { printf '  \033[33m%-28s %s\033[0m\n' "$1" "$2"; }

backed_up=0

# link_file <source> <target>
link_file() {
  local src="$1" dst="$2"
  local name="${dst#$HOME/}"

  if [ ! -e "$src" ]; then
    warn "$name" "source missing, skipped"
    return
  fi

  # Already pointing where we want it
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    skip "$name"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
      printf '  %-28s exists. replace? [y/N] ' "$name"
      read -r reply </dev/tty
      case "$reply" in
        [yY]*) ;;
        *) warn "$name" "kept existing"; return ;;
      esac
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      warn "$name" "would back up and replace"
    else
      mkdir -p "$BACKUP/$(dirname "$name")"
      mv "$dst" "$BACKUP/$name"
      backed_up=1
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    [ -e "$dst" ] || link "$name" "${src#$DOTFILES/}"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  link "$name" "${src#$DOTFILES/}"
}

echo
echo "dotfiles: $DOTFILES"
[ "$DRY_RUN" -eq 1 ] && echo "mode:     dry run (nothing will change)"
echo

# ---- ~/ dotfiles ----
echo "home:"
for src in "$DOTFILES"/home/.[!.]*; do
  [ -e "$src" ] || continue
  link_file "$src" "$HOME/$(basename "$src")"
done

# ---- ~/.config ----
echo
echo "config:"
for src in "$DOTFILES"/config/*/; do
  [ -d "$src" ] || continue
  link_file "${src%/}" "${XDG_CONFIG_HOME:-$HOME/.config}/$(basename "$src")"
done

echo
if [ "$backed_up" -eq 1 ]; then
  echo "Replaced files backed up to: $BACKUP"
fi

cat <<'EOF'
Next steps:

  - Local/work settings go in ~/.bash_work (untracked, sourced last by .bashrc)
  - Packages:  see packages/apt.txt, npm-global.txt, go-tools.txt
  - Manual installs (st, nvim, go, nvm, fonts): see packages/manual.md
  - Start a new shell, or: exec bash -l

EOF
