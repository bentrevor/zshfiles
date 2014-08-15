ZSH_THEME="norm"
COMPLETION_WAITING_DOTS="true"

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
    platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
    platform='osx'
fi

function linux() {
    [[ $platform == 'linux' ]]
}

function osx() {
    [[ $platform == 'osx' ]]
}

export DEFAULT_PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export PATH=$DEFAULT_PATH

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
setopt EXTENDED_HISTORY     # add timestamps to history
setopt APPEND_HISTORY       # adds history
setopt INC_APPEND_HISTORY   # adds history incrementally
setopt SHARE_HISTORY        # share across sessions
setopt HIST_IGNORE_ALL_DUPS # don't record dupes in history
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

source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby ruby 2.1

export DEFAULT_GEM_HOME=$GEM_HOME
export DEFAULT_GEM_PATH=$GEM_PATH

if linux; then
    prompt_branch_color='green'
    prompt_dir_color='blue'
    prompt_vm_color='cyan'
    alias ls='ls --color'

    export PATH=~/8b/bin:$PATH
else
    prompt_branch_color='yellow'
    prompt_dir_color='red'
    alias ls='ls -G'

    source $(brew --prefix)/etc/profile.d/z.sh

    source ~/.zsh/export_homebrew_github_api_token.sh

    export CC=/usr/local/Cellar/apple-gcc42/4.2.1-5666.3/bin/gcc-4.2
    export CXX=/usr/local/Cellar/apple-gcc42/4.2.1-5666.3/bin/g++-4.2
    export CPP=/usr/local/Cellar/apple-gcc42/4.2.1-5666.3/bin/cpp-4.2
fi

function vm_has_a_name() {
    grep -q 'config.vm.define' /vagrant/Vagrantfile
}

function linux_vm_name() {
    if [[ -e "$HOME/.vm-name" ]]; then
        cat "$HOME/.vm-name"
    fi
}

function change_color() {
    echo "%{$fg_bold[$1]%}$2%{$reset_color%}"
}

function current_vm() {
    if osx; then
        echo ''
    else
        echo "[$(change_color $prompt_vm_color $(linux_vm_name))] "
    fi
}

function current_dir() {
    echo "[$(change_color $prompt_dir_color %~)]"
}

function current_branch() {
    if [[ -a .git/refs/heads ]] || [[ -a ../.git/refs/heads ]] || [[ -a ../../.git/refs/heads ]]; then
        ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
        echo "[$(change_color $prompt_branch_color ${ref#refs/heads/})] "
    else
        echo ""
    fi
}

export PS1='$(current_vm)$(current_branch)$(current_dir) '

# aliases
alias l='ls -lhpG'
alias lsa='ls -lhpA'

alias e='emacs'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias t='tree -C --dirsfirst'
alias t2='tree -C --dirsfirst -L 2'

# make aliases work with "sudo"
alias sudo='sudo '

alias showpath="echo $PATH | tr : '\n'"

# let tmux use 256 colors
alias tmux='tmux -2'

alias be='bundle exec'

alias gl="git log --graph --date=short --format=format:'%C(blue)%h%C(white) %C(240)- %C(white)%s%C(240) -- %an, %ad'"
alias gd='git diff'
alias gs='git status'
alias gb='git branch'

alias pgstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias pgstop="pg_ctl -D /usr/local/bin/postgres stop -s -m fast"
alias pryr="pry -r ./config/environment -r rails/console/app -r rails/console/helpers"
alias enova="cd ~/8b/brands/netcredit"

alias scm='scheme-r5rs'
alias wget_mirror='wget --mirror -p --html-extension --convert-links'
alias df='df -h' # human-readable output

if [[ -a ~/.vpn_functions ]]; then
    source ~/.vpn_functions
fi

export FIX_VPN_POW=yes
export FIX_VPN_MINIRAISER=yes

function in_git_project() {
    [[ -e ./.git ]]
}

export GEM_REPOS=~/.gem/repos


function gemp() {
    project=$(basename $(pwd))

    new_gem_home=$GEM_REPOS/$project
    new_path=$new_gem_home/bin:$PATH

    printable_gem_path=$(echo $GEM_PATH | sed 's/:/\\n\\t\\t/g')
    printable_path=$(echo $new_path | sed 's/:/\\n\\t\\t/g')

    changes="New \$GEM_HOME:\t$new_gem_home\n\n\$GEM_PATH:\t$printable_gem_path\n\nNew \$PATH:\t$printable_path\n\n"

    case "$1" in
	-h|--help)
	    echo "Usage: TODO"
	    ;;
        --dry-run)
            echo $changes
            ;;
	list)
	    ls -l $GEM_REPOS
	    ;;
        reset)
            export PATH=$DEFAULT_PATH
            export GEM_HOME=$DEFAULT_GEM_HOME
            export GEM_PATH=$DEFAULT_GEM_PATH
            ;;
	"")
            if ! in_git_project; then
                echo '`git init` first'
            else
                mkdir -p ${new_gem_home}
                export GEM_HOME=${new_gem_home}
                export PATH=${new_path}

                echo $changes
            fi
	    ;;
    esac
}

# gets executed whenever the pwd changes, can run a list of functions by making chpwd_functions array
function chpwd() {
    local project=$(basename $PWD)

    if in_git_project; then
        if [[ -d $GEM_REPOS/$project ]]; then
            echo "gem repo $project already exists"
        else
            echo "gem repo $project doesn't exist yet - create it with \`gemp\`"
        fi
    fi
}
