alias ll='ls -lAhXi --group-directories-first'
alias lt='ls -lAhXit --group-directories-first'
alias ld='ls -lhp --group-directories-first | grep '/' '
alias l='ls -CFhAX --group-directories-first'
alias lb='sudo du -Sh | sort -rh | head'

alias dubig="sudo du -Sh | sort -rh | head"
alias pnum="dpkg -l | grep '^.i' | awk '{print $2}' | wc -l"

alias btc='bitcoin-cli'
alias pff='firefox --private-window'
