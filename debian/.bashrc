# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Run in vi mode
set -o vi

# Variables for ranger
VISUAL=vim;
export VISUAL EDITOR=vim;
export EDITOR;

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=40000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# custom shit for your prompt
# source "/usr/share/git/completion/git-prompt.sh"

GIT_PS1_SHOWDIRTYSTATE=1;
GIT_PS1_SHOWCOLORHINTS=1;
GIT_PS1_SHOWUNTRACKEDFILES=1;

SH_WHITE="\[\033[1;37m\]"
SH_BLUE="\[\033[1;34m\]"
SH_RED="\[\033[1;31m\]"
SH_GREEN="\[\033[1;32m\]"
SH_YELLOW="\[\033[1;33m\]"

BL_ANGLE="\342\224\224"
TL_ANGLE="\342\224\214"
HORIZ_LINE="\342\224\200"

BATT="\$(acpi -b | awk '{print \$4}' | cut -b1-3)"
FILES_STAT="\$(ls -1 | wc -l | sed 's: ::g')"
FILES_SIZE="\$(ls -lah | grep -m 1 total | sed 's/1:total //')b"
GIT_PS1='$(__git_ps1 "(%s)")'

if [ $UID -eq 0 ]; then
    PS1='\[\e[0;31m\]\u\[\e[m\]\[\e[1;37m\]@\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;32m\]'
elif [ -n "$SSH_CLIENT" ]; then
    PS1='\[\e[0;31m\](SSH)\[\e[m\]\[\e[1;37m\]\u@\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] \[\e[1;32m\]$(acpi -b | awk "{print \$4}" | cut -b1-3) $(__git_ps1 "(%s) ")\$\[\e[m\] \[\e[1;32m\]'
else
    PS1="\n"${TL_ANGLE}"(\u@\h)"${SH_GREEN}""${HORIZ_LINE}"("${SH_GREEN}"\$?)"${HORIZ_LINE}"(\@ \d)\n"${BL_ANGLE}${HORIZ_LINE}"("${SH_GREEN}"\w)"${HORIZ_LINE}"("${FILES_STAT}" files, "${FILES_SIZE}")"${HORIZ_LINE}${GIT_PS1}"> "${SH_GREEN}
fi
trap 'echo -ne "\e[0m"' DEBUG

# Echo on startup:

lain() {

. /etc/os-release

SH_GREEN="\033[1;32m"
NC="\033[0m"

NOPKG="$(apt list --installed 2> /dev/null | wc -l)";
NOPKGS="$(($NOPKG-1))"

echo -ne "${SH_GREEN}+=I?~~IIIII++,:   .?= .,I=O8OZ.DNNO, ZD7:::=.? ,,:,,I,,:,~+?II?I?II?=+=~+7S      time: "; date +%r
echo -ne "${SH_GREEN}++??==+I???7..:.   :IIS77?I+ID~NND8.ZMN7~=~I7:,., :?7,.,.~+?I???????,+~7+SZ      date: "; date +%b' '%d,' '%Y' ('%a')'
echo -ne "${SH_GREEN}==I+~===?I77:  ?   ,S7S.:.,I?=7NNNINMMMNOI=++ .~==IS7, ..++?I???I+=?.+:O+ZZ    uptime: "; uptime -p | cut -c4-
echo -ne "${SH_GREEN}++I+==?III??I,?,   ~I7NN,..  ??ONNNMMMDS777S7ISZOOS7?....+=????I~=+,:+,O8DN       ram: "; free -h | awk 'BEGIN {ORS=""} FNR == 2 {print $3}'; echo -ne ' / '; free -h | awk ' FNR == 2 {print $2}';
echo -ne "${SH_GREEN}==7II=+I?II7I,I+,8Z.II8D+=~:.,7SNMMMMMN8S7~. ..  :88I. ..?=?++I:~+=.~~~NMMM    distro: "; echo $PRETTY_NAME | sed 's/GNU\/Linux //';
echo -ne "${SH_GREEN}==II?I~+?I?S7I?~8D7+7SZZNONDN8Z8NMMMMMMNNON:=. :,S.I7  .,+=??I:,=, .:,=DNNM    kernel: "; uname -r
echo -ne "${SH_GREEN}==+==?~+=I?SSI+88D:IS8NMNDDNNNDNNNMMMMMMMMM8IS77=MMDO.  :~=+?,,,   .~,?8DDD       hdd: "; df -h | awk 'BEGIN {ORS=""} FNR == 2 {print $3}'; echo -ne ' / '; df -h | awk ' FNR == 2 {print $2}';
echo -ne "${SH_GREEN}+==I7I=IIIIOS=~OOD=I7ODNNNNMNNDNDNMMMMMMMMNOSO+OZ 78.,.I::++:..   .,::=888O      bash: "; echo $BASH_VERSION
echo -ne "${SH_GREEN}I=I?~=?I???SIS?OODZ=7Z8NDONNN7D88MMMMMMMMMMNNNN8DNN~..~:7,,+7?,:,:::+8=Z888       cpu: "; lscpu | awk 'FNR == 13 {print $3 " " $4 " " $5}';
echo -ne "${SH_GREEN}==7?=??I????7Z7ZOD8I777S+NNN:OOZOMMMMMMMMMMMMMMNMM+..~=?=O:+?::=+~:~+IDD88O        de: "; echo $XDG_CURRENT_DESKTOP
echo -ne "${SH_GREEN}II??=I???=::7OI?O88Z=I~,?ZDD,ZSIDMMMMMMMMMMMMMMMM:SS?.~?+=?:,~+?I??==+++I8O       pkg: "; echo $NOPKGS
echo -e "${SH_GREEN}++??+=.,~,~:7ZS?7I77S=. SIS8IS7+~8NMMMMMMMMMMMMDDMNS ,:+?=.~==?II+++=+=?II+"
echo -e "${SH_GREEN}?+I?,=:+?=~~??I++~7SSS= 777Z,SZSSONNMMMMMMMMMMMMMM8? .~=?:.==+?I~+?=+=??II?"
echo -e "${SH_GREEN}?I:=~??II=~~, II?+ 7S7?=?77S?SZ:8NMMMNMMMMMMMMMMMD7 ,,===::~=?II.??++?++III"
echo -e "${SH_GREEN}.I+I=+I+??=~=~ =I+:?7S77?SSSZI7Z8DM7NMMNMMMMMMMMOI. .,=~~.~~+I?:???==~????I"
echo -e "${SH_GREEN}:==?I++I?~==+=~:.?I7I77S?IZSZODDOIDNNNNNMMMMNM8?.:. ,,+=,::~+==II=~,=?+?III"
echo -e "${SH_GREEN}:?=,=+++?II+=:,:, +77777SS777ODDMMNO~DNNNDD8?..::: .,,+~.,::=??????=+?IIIII"
echo -e "${SH_GREEN}?++=~:=?IIIII=~:: ~~+II77SS7SZO8NMMMND.+:   .=7+=~ ,,:?...~II??+??I?+??IIII"
echo -e "${SH_GREEN}II7II+~:?II7+II?, ~,:,~7777SSSIS8DNMMNO   .~I  .Z:.,:~: ,+???+=,IIIIII??III"
# echo -e "${SH_GREEN}??I7I:,~=:,+II+=~I??:.,,,.:77777777SODMM8 .:+ZI. ,~,..~~ :II?==~:?II??IIIIIIII"
}

# Timestampped history
export HISTTIMEFORMAT="%y/%m/%d %T "

# added by Anaconda2 installer
export PATH="/home/user/anaconda2/bin:$PATH"

# added by Miniconda3 installer
export PATH="/home/user/miniconda3/bin:$PATH"

export PATH=$PATH:/home/user/.go/bin

export GOPATH=/home/user/go

export PATH=$PATH:/home/user/go/bin
