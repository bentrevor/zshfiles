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

# function my-move-cursor() {
#     spacesToNextWord=5
#     echo -en "\033[${spacesToNextWord}C"
# }

# zle -N my-move-cursor
# bindkey "^[w" my-move-cursor                     # make delete key work


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
    fi
}

export COMMAND_LOGGING=true

function dont_log_that() {
    local ocl=$COMMAND_LOGGING
    export COMMAND_LOGGING=false
    echo -e '$d\n$d\nwq' | ed ~/.full_history # deletes last two lines ( one is `export COMMAND_LOGGING=false`)
    export COMMAND_LOGGING=$ocl
}

function log_commands() {
    if [[ $(cat ~/.full_history | wc -l) -gt 3000 ]]; then
        echo 'logging ~/.full_history'
        mv ~/.full_history ~/terminal_histories/$(date +%Y_%m_%d)
        touch ~/.full_history
    fi
    [[ $COMMAND_LOGGING = true ]] && echo "$(date '+%Y-%m-%d\t%H:%M')\t$(pwd)\t$1" >> ~/.full_history
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
    _Z_EXCLUDE_DIRS=("$HOME/.gem" "$HOME/.rubies" "$HOME/Library" "$HOME/work/enova/8b/gems/portfolio_client" "$HOME/work/enova/8b/gems/identity_client")
    # source ~/.zsh/export_homebrew_github_api_token.sh
fi


### Prompt ###
# first line of `git status` is either `On branch xxx` or `HEAD detached at xxx`
function nth_word_of_gs()       { git status | head -1 | awk "{print \$$1}" }
function detached_head()        { [[ $(nth_word_of_gs 2) == 'detached' ]] }
function detached_head_status() { nth_word_of_gs 4 }
function attached_head_status() { nth_word_of_gs 3 }

function current_dir()    { echo "[%{$fg_bold[$prompt_path_color]%}%~%{$reset_color%}]" }
function current_branch() {
    if [[ -a .git/refs/heads ]] || [[ -a ../.git/refs/heads ]] || [[ -a ../../.git/refs/heads ]]; then
        if detached_head; then
            branch=$(detached_head_status)
        else
            branch=$(attached_head_status)
        fi
        echo "[%{$fg_bold[$prompt_branch_color]%}$branch%{$reset_color%}] "
    else
        echo ""
    fi
}
export PS1='$(current_branch)$(current_dir) '

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

# for some reason, `be re` doesn't work
function bere() {
    echo ''
    echo "$(dull_red PATH:)"
    bundle exec echo "$(echo $PATH | tr ':' '\n')
        $(dull_red GEM_HOME)      =>      $GEM_HOME
        $(dull_red GEM_ROOT)      =>      $GEM_ROOT
        $(dull_red GEM_PATH)      =>      $GEM_PATH
        $(dull_red GEM_GROUP)     =>      $GEM_GROUP

        $(dull_red RUBY_ENGINE)   =>      $RUBY_ENGINE
        $(dull_red RUBY_ROOT)     =>      $RUBY_ROOT"
}

# add WTFPL license
function wtfpl() {
    if [ -f COPYING ]; then
        echo 'COPYING file already exists'
    else
        cat > COPYING <<- EOM
        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2015 Ben Trevor <benjamin.trevor@gmail.com>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
EOM
    fi
}

function hoog() {
  hoogle $@ | head -5
}

function colortest() {
    for x in 0 1 4 5 7 8; do
        for i in `seq 30 37`; do
            for a in `seq 40 47`; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m ";
            done;
            echo;
        done;
    done;

    echo "";
}

function rename_box() {
    OLD_BOX_NAME=$1
    PROVIDER=$2
    NEW_BOX_NAME=$3

    echo "repackaging $OLD_BOX_NAME..."
    vagrant box repackage $OLD_BOX_NAME $PROVIDER
    echo "adding $NEW_BOX_NAME..."
    vagrant box add $NEW_BOX_NAME package.box
    rm package.box
    vagrant box remove $OLD_BOX_NAME
    echo 'Success!'
}

# for debugging
cat ~/.zshrc > ~/.loaded_zshrc

### set up session ###
function global_bins()  { echo '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }
function gem_bins()     { echo "$GEM_HOME/bin" }
function cabal_bins()     { echo "$HOME/.cabal/bin" }
# function go_bins()      { echo "$GOPATH/bin" }

# export GOPATH=$HOME/go
export PATH=$(gem_bins):$(global_bins):$(cabal_bins)
chpwd
