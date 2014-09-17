### ZSH settings ###
ZSH_THEME="norm"
COMPLETION_WAITING_DOTS="true"
plugins=(git github heroku lein battery cp git-extras)

platform='unknown'
[[ $(uname) == 'Linux' ]]  && platform='linux'
[[ $(uname) == 'Darwin' ]] && platform='osx'

function linux() { [[ $platform == 'linux' ]] }
function osx()   { [[ $platform == 'osx' ]]   }

### Completion ###
fpath=(~/.zsh/completion $fpath) # add custom completion to fpath
setopt COMPLETE_IN_WORD
autoload -U compinit
compinit
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case insensitive completion
zstyle ':completion:*:default' menu 'select=0'      # menu-style

### Colors ###
export CLICOLOR=1
autoload colors
colors
source ~/junk_drawer/scripts/color_functions.sh # Color helper functions

### History ###
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

### more ZSH settings ###
unsetopt correct_all
bindkey -e                                       # use emacs key bindings
bindkey '^r' history-incremental-search-backward # make Control-r work
bindkey '^[[Z' reverse-menu-complete             # shift-tab to cycle backwards
bindkey "^[[3~" delete-char                      # make delete key work
bindkey "^[3;5~" delete-char                     # make delete key work
autoload -U select-word-style
select-word-style bash

setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS   # allow functions to have local traps
setopt PROMPT_SUBST
setopt AUTO_CD
stty -ixon -ixoff    # disable scroll lock
export EDITOR=vim
set -o emacs
for config_file ($HOME/.zsh/*.zsh(.N)) source $config_file # Load other config files

### OS-specific settings ###
if linux; then
    alias ls='ls --color'
else
    alias ls='ls -G'

    source $(brew --prefix)/etc/profile.d/z.sh
    source ~/.zsh/export_homebrew_github_api_token.sh
fi

### Prompt ###
function current_dir()    { echo "[%{$fg_bold[blue]%}%~%{$reset_color%}]" }
function current_branch() {
    if [[ -a .git/refs/heads ]] || [[ -a ../.git/refs/heads ]] || [[ -a ../../.git/refs/heads ]]; then
        ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
        echo "[%{$fg_bold[green]%}${ref#refs/heads/}%{$reset_color%}] "
    else
        echo ""
    fi
}
export PS1='$(current_branch)$(current_dir) '

### Enova ###
[[ -a ~/.vpn_functions ]] && source ~/.vpn_functions
export FIX_VPN_POW=yes
export FIX_VPN_MINIRAISER=yes

### Helpers ###
function show-path()        { echo $PATH | tr ':' '\n' }
function show-colors()      { source ~/junk_drawer/scripts/color_functions.sh --debug }
function show-bold-colors() { source ~/junk_drawer/scripts/color_functions.sh --bold }

# for debugging
cat ~/.zshrc > ~/.loaded_zshrc

### set up session ###
reset_paths
cd .
