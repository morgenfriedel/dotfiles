# ~/.bashrc: executed by bash(1) for interactive *non-login* shells.

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *)   return;;
esac

##### 1. PATH #####

[ -f "$HOME/.bash_path" ] && . "$HOME/.bash_path"

##### 2. Basic env / editor / mode #####

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=st
export BROWSER=google-chrome

# Terminal colorscheme (base16). See packages/manual.md for installation.
[ -x "$HOME/theme.sh" ] && "$HOME/theme.sh" soft-server

# vi mode in readline
set -o vi

##### 3. History & shell behavior #####

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# big but finite history
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command
shopt -s checkwinsize

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

##### 4. Prompt helpers & terminal title #####

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

##### 5. Colors, aliases, completion #####

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# "alert" alias for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

##### 6. Functions & prompt #####

[ -f "$HOME/.bash_functions" ] && . "$HOME/.bash_functions"
[ -f "$HOME/.bash_prompt"    ] && . "$HOME/.bash_prompt"

##### 7. NVM (keep near the end; their recommendation) #####

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

##### 8. Local overrides (untracked) #####

# Work- and machine-specific settings that are deliberately not published:
# employer paths, internal hosts, AWS profiles, credentials-adjacent config.
# Sourced last so it can override anything defined above.
[ -f "$HOME/.bash_work" ] && . "$HOME/.bash_work"
