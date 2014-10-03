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
[[ -d ~/junk_drawer ]] && source ~/junk_drawer/scripts/color_functions.sh # Color helper functions

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

source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh/zshenv_scripts/aliases.zsh

function chpwd() {
    if osx; then
        [[ $CHRUBY_AUTOSWITCH = true ]] && chruby_auto
        [[ -e ~/.z ]] && prune_z
    fi
}

function log_commands() {
    [[ $(cat ~/.full_history | wc -l) -gt 20000 ]] && echo "~/.full_history is getting pretty big..."
    echo "$(date '+%d/%m/%Y\t%H:%M')\t$(pwd)\t$1" >> ~/.full_history
}

if [[ ! "$preexec_functions" == *log_commands* ]]; then
    preexec_functions+=("log_commands")
fi

### OS-specific settings ###
if linux; then
    prompt_branch_color='yellow'
    prompt_path_color='red'
    alias ls='ls --color'
else
    prompt_branch_color='green'
    prompt_path_color='blue'
    alias ls='ls -G'

    source $(brew --prefix)/etc/profile.d/z.sh
    source ~/.zsh/export_homebrew_github_api_token.sh
fi


### Prompt ###
function current_dir()    { echo "[%{$fg_bold[$prompt_path_color]%}%~%{$reset_color%}]" }
function current_branch() {
    if [[ -a .git/refs/heads ]] || [[ -a ../.git/refs/heads ]] || [[ -a ../../.git/refs/heads ]]; then
        ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
        echo "[%{$fg_bold[$prompt_branch_color]%}${ref#refs/heads/}%{$reset_color%}] "
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

# ruby environment
function re() {
    echo ''
    echo "$(dull_red PATH:)"
    show-path
    echo ''
    echo "$(dull_red GEM_HOME) \t=>\t$GEM_HOME"
    echo "$(dull_red GEM_ROOT) \t=>\t$GEM_ROOT"
    echo "$(dull_red GEM_PATH) \t=>\t$GEM_PATH"
    echo "$(dull_red GEM_GROUP) \t=>\t$GEM_GROUP"
    echo ''
    echo "$(dull_red RUBY_ENGINE) \t=>\t$RUBY_ENGINE"
    echo "$(dull_red RUBY_ROOT) \t=>\t$RUBY_ROOT"
}

# for debugging
cat ~/.zshrc > ~/.loaded_zshrc

### set up session ###
function global_bins()  { echo '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }
function haskell_bins() { echo "$HOME/Library/Haskell/bin" }
function gem_bins()     { echo "$GEM_HOME/bin" }
function 8br_bins()     { echo "$HOME/work/enova/8b/bin" }

export PATH=$(8br_bins):$(haskell_bins):$(gem_bins):$(global_bins)
chpwd
