### Aliases ###
alias l='ls -lhpG'
alias lsa='ls -lhpA'

alias e='emacs'
alias erc='emacs -e "run-erc"'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias grip='grep -i --color=auto'

alias t='tree -C --dirsfirst -I "coverage|build|dist" '
alias t2='t -L 2'

# make aliases work with "sudo"
alias sudo='sudo '

# escape square brackets
alias ng='noglob '

# let tmux use 256 colors
alias tmux='tmux -2'

alias be='bundle exec'

alias gl="git log --graph --date=short --format=format:'%C(blue)%h%C(white) %C(240)- %C(white)%s%C(240) -- %an, %ad'"

alias pgstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias pgstop="pg_ctl -D /usr/local/bin/postgres stop -s -m fast"

alias scm='scheme-r5rs'
alias wget_mirror='wget --mirror -p --html-extension --convert-links'
alias df='df -h' # human-readable output
alias bdi='$(boot2docker shellinit)'
