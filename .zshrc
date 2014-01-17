ZSH=$HOME/.oh-my-zsh

ZSH_THEME="norm"
COMPLETION_WAITING_DOTS="true"

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='osx'
fi

# Path
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH

plugins=(git
         github
         heroku
         lein
         battery
         cp
         git-extras)

# Completion
# add custom completion to fpath
fpath=(~/.zsh/completion $fpath)

setopt COMPLETE_IN_WORD
autoload -U compinit
compinit
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case insensitive completion
zstyle ':completion:*:default' menu 'select=0' # menu-style

# Colors
export CLICOLOR=1
autoload colors
colors

# History
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt EXTENDED_HISTORY # add timestamps to history
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY # adds history incrementally
setopt SHARE_HISTORY # share across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
unsetopt correct_all
bindkey -e # use emacs key bindings
bindkey '^r' history-incremental-search-backward # make Control-r work
bindkey '^[[Z' reverse-menu-complete
bindkey "^[[3~" delete-char # make delete key work
bindkey "^[3;5~" delete-char

autoload -U select-word-style
select-word-style bash

# Miscellaneous Options
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt AUTO_CD
stty -ixon -ixoff # disable scroll lock
export EDITOR=vim
set -o emacs

# Load other config files
for config_file ($HOME/.zsh/*.zsh(.N)) source $config_file

# differences between osx and linux
if [[ $platform == 'linux' ]]; then
  promptcolor1='green'
  promptcolor2='blue'
  alias ls='ls --color'
elif [[ $platform == 'osx' ]]; then
  promptcolor1='yellow'
  promptcolor2='red'
  alias ls='ls -G'
fi

# prompt
export PATH=$HOME/.bin:$PATH

git_prompt_info() {
  ref=$($(which hub) symbolic-ref HEAD 2> /dev/null) || return
  user=$($(which hub) config user.name 2> /dev/null)
  echo "[%{$fg_bold[$promptcolor1]%}${user}@${ref#refs/heads/}%{$reset_color%}]"
}

export PS1='$(git_prompt_info)[%{$fg_bold[$promptcolor2]%}%~%{$reset_color%}] '

# aliases
alias l='ls -lhpG'
alias lsa='ls -lhpA'

# use color with grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias t='tree -C --dirsfirst'
alias t2='tree -C --dirsfirst -L 2'

# make aliases work with "sudo"
alias sudo='sudo '

# better `echo $PATH` output
alias showpath="echo $PATH | tr : '\n'"

# let tmux use 256 colors
alias tmux='tmux -2'

# git aliases
alias gitlog='git log --graph --pretty=format:"   %s"'
alias gd='git diff'
alias gs='git status'
alias gb='git branch'

# load boxen environment
source /opt/boxen/env.sh

# add rbenv command
export PATH="$HOME/.rbenv/bin:$PATH"

# add rbenv init to shell
eval "$(rbenv init -)"

