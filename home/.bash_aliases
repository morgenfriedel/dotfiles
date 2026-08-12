# ~/.bash_aliases - generic aliases
#
# Machine- or employer-specific aliases belong in ~/.bash_work, which is
# untracked and sourced last by ~/.bashrc.

##### Listing #####

alias ll='ls -lAhXi --group-directories-first'
alias lt='ls -lAhXit --group-directories-first'
alias ld='ls -lhp --group-directories-first | grep '/' '
alias l='ls -CFhAX --group-directories-first'
alias lb='sudo du -Sh | sort -rh | head'

##### System #####

alias dubig="sudo du -Sh | sort -rh | head"
alias pcount="dpkg -l | grep '^.i' | awk '{print $2}' | wc -l"
alias sapt='sudo apt update --fix-missing && sudo apt upgrade -y --allow-downgrades && sudo apt install -f && sudo apt clean && sudo apt autoremove -y'

alias tocb='xclip -selection clipboard'

##### Applications #####

alias pff='firefox --private-window'
alias python='python3'

##### Node #####

alias npr='npm run'
alias npt='npx ts-node'

# List packages linked into node_modules with `npm link`
alias yll="find . -type l | grep -v .bin | sed 's/^\.\/node_modules\///'"

##### Neovim #####

# Distraction-free prose editing (Goyo + minimal UI)
alias tvim="nvim -u ~/.config/nvim/text-config.vim"
