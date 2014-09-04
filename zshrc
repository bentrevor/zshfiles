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

export GEM_GROUP_AUTOSWITCH=true
export GEM_GROUP_DIR=~/.gem/groups
mkdir -p $GEM_GROUP_DIR

function set_gem_group() {
    if in_ruby_project; then
        export GEM_GROUP=$(basename $(pwd))
    else
        unset GEM_GROUP
    fi
}

function set_gem_path()  {
    export GEM_PATH=$RUBY_ROOT
}

function set_gem_home() {
    if [[ -n $GEM_GROUP ]]; then
        export GEM_HOME=$GEM_GROUP_DIR/$GEM_GROUP
    else
        export GEM_HOME=$RUBY_ROOT
    fi
}

function reset_paths() {
    set_gem_path
    set_gem_home

    export PATH=$(gem_bins):$(ruby_bins):$(global_bins)
}

function global_bins() {
    echo '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
}

function ruby_bins() {
    echo "$RUBY_ROOT/bin"
}

function gem_bins() {
    echo "$GEM_HOME/bin"
}

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
source ~/junk_drawer/scripts/color_functions.sh # Color helper functions

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

# Load other config files (syntax highlighting)
for config_file ($HOME/.zsh/*.zsh(.N)) source $config_file

if linux; then
    alias ls='ls --color'
else
    alias ls='ls -G'

    source $(brew --prefix)/etc/profile.d/z.sh
    source ~/.zsh/export_homebrew_github_api_token.sh
fi

function change_color() {
    echo "%{$fg_bold[$1]%}$2%{$reset_color%}"
}

function current_dir() {
    echo "[$(dull_blue %~)]"
}

function current_branch() {
    if [[ -a .git/refs/heads ]] || [[ -a ../.git/refs/heads ]] || [[ -a ../../.git/refs/heads ]]; then
        ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
        echo "[$(tput bold)$(hot_cyan ${ref#refs/heads/})] "
    else
        echo ""
    fi
}

export PS1='$(current_branch)$(current_dir) '

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

function show-path() {
    echo $PATH | tr ':' '\n'
}

export FIX_VPN_POW=yes
export FIX_VPN_MINIRAISER=yes

# gem groups
function gg() {
    export GEM_GROUP=$(basename $(pwd))

    local new_gem_home=$GEM_GROUP_DIR/$GEM_GROUP
    local printable_gem_path=$(echo $GEM_PATH | sed 's/:/\\n\\t\\t/g')

    changes="New $(hot_magenta \$GEM_HOME):\t$new_gem_home\n\n$(hot_magenta \$GEM_PATH):\t$printable_gem_path\n"

    case "$1" in
        -h|--help)
            echo "Usage: TODO"
            ;;

        --dry-run)
            echo $changes
            ;;

        list|-l)
            ls -l $GEM_GROUP_DIR
            ;;

        # FIXME
        # reset)
        #     export PATH=$DEFAULT_PATH
        #     export GEM_HOME=$DEFAULT_GEM_HOME
        #     export GEM_PATH=$DEFAULT_GEM_PATH
        #     ;;

        remove)
            echo "removing gem group $(hot_magenta $2)"
            rm -rf $GEM_GROUP_DIR/$2
            ;;

        dir)
            echo $GEM_GROUP_DIR
            ;;

        # FIXME
        # use)
        #     echo "using gem group $(hot_green $2)"
        #     gg $2
        #     ;;

        # use the current directory name by default
        "")
            if ! in_ruby_project; then
                echo 'must be in ruby project'
            else
                mkdir -p ${new_gem_home}
                export GEM_HOME=${new_gem_home}

                echo $changes
            fi
            ;;
    esac
}

# TODO consolidate these
function find_gemfile() {
    IN_RUBY_PROJECT=false
    local dir="$PWD"

    until [[ -z "$dir" ]]; do
        if [[ -e "$dir/Gemfile" ]]; then
            gem_group_name=$(basename $dir)
            IN_RUBY_PROJECT=true
            return
        fi

        dir="${dir%/*}"
    done
}

function find_git_dir() {
    IN_GIT_REPO=false
    local dir="$PWD"

    until [[ -z "$dir" ]]; do
        if [[ -e "$dir/.git" ]]; then
            IN_GIT_REPO=true
            return
        fi

        dir="${dir%/*}"
    done
}

function in_ruby_project() {
    find_git_dir
    find_gemfile
    [[ $IN_GIT_REPO = true ]] && [[ $IN_RUBY_PROJECT = true ]]
}

# ruby environment
function re() {
    echo ''
    echo "$(hot_magenta PATH:)"
    show-path
    echo ''
    echo "$(hot_magenta GEM_PATH) \t=>\t$GEM_PATH"
    echo "$(hot_magenta GEM_HOME) \t=>\t$GEM_HOME"
    echo "$(hot_magenta GEM_ROOT) \t=>\t$GEM_ROOT"
    echo "$(hot_magenta GEM_GROUP) \t=>\t$GEM_GROUP"
    echo "$(hot_magenta RUBY_ENGINE) \t=>\t$RUBY_ENGINE"
    echo "$(hot_magenta RUBY_ROOT) \t=>\t$RUBY_ROOT"
}

# gets executed whenever the pwd changes
# can run a list of functions by making chpwd_functions array
function chpwd() {
    # autoswitch_ruby
    # autoswitch_gem_group
    # reset_paths

    # if in_ruby_project; then
    #     echo 'in a ruby project'
    # fi
}

# for debugging
cat ~/.zshrc > ~/loaded_zshrc

# chruby.sh
CHRUBY_VERSION="0.3.8"
RUBIES=()

for dir in "$PREFIX/opt/rubies" "$HOME/.rubies"; do
    [[ -d "$dir" && -n "$(ls -A "$dir")" ]] && RUBIES+=("$dir"/*)
done
unset dir

function chruby_reset()
{
    [[ -z "$RUBY_ROOT" ]] && return

    PATH=":$PATH:"; PATH="${PATH//:$RUBY_ROOT\/bin:/:}"

    if (( $UID != 0 )); then
        [[ -n "$GEM_HOME" ]] && PATH="${PATH//:$GEM_HOME\/bin:/:}"
        [[ -n "$GEM_ROOT" ]] && PATH="${PATH//:$GEM_ROOT\/bin:/:}"

        GEM_PATH=":$GEM_PATH:"
        [[ -n "$GEM_HOME" ]] && GEM_PATH="${GEM_PATH//:$GEM_HOME:/:}"
        [[ -n "$GEM_ROOT" ]] && GEM_PATH="${GEM_PATH//:$GEM_ROOT:/:}"
        GEM_PATH="${GEM_PATH#:}"; GEM_PATH="${GEM_PATH%:}"
        unset GEM_ROOT GEM_HOME
        [[ -z "$GEM_PATH" ]] && unset GEM_PATH
    fi

    PATH="${PATH#:}"; PATH="${PATH%:}"
    unset RUBY_ROOT RUBY_ENGINE RUBY_VERSION RUBYOPT
    hash -r
}

function chruby_use()
{
    if [[ ! -x "$1/bin/ruby" ]]; then
        echo "chruby: $1/bin/ruby not executable" >&2
        return 1
    fi

    [[ -n "$RUBY_ROOT" ]] && chruby_reset

    export RUBY_ROOT="$1"
    export RUBYOPT="$2"
    export PATH="$RUBY_ROOT/bin:$PATH"

    eval "$("$RUBY_ROOT/bin/ruby" - <<EOF
puts "export RUBY_ENGINE=#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'};"
puts "export RUBY_VERSION=#{RUBY_VERSION};"
begin; require 'rubygems'; puts "export GEM_ROOT=#{Gem.default_dir.inspect};"; rescue LoadError; end
EOF
)"

    if (( $UID != 0 )); then
        export GEM_HOME="$HOME/.gem/$RUBY_ENGINE/$RUBY_VERSION"
        export GEM_PATH="$GEM_HOME${GEM_ROOT:+:$GEM_ROOT}${GEM_PATH:+:$GEM_PATH}"
        export PATH="$GEM_HOME/bin${GEM_ROOT:+:$GEM_ROOT/bin}:$PATH"
    fi
}

function chruby()
{
    case "$1" in
        -h|--help)
            echo "usage: chruby [RUBY|VERSION|system] [RUBYOPT...]"
            ;;
        -V|--version)
            echo "chruby: $CHRUBY_VERSION"
            ;;
        "")
            local dir star
            for dir in "${RUBIES[@]}"; do
                dir="${dir%%/}"
                if [[ "$dir" == "$RUBY_ROOT" ]]; then star="*"
                else                                  star=" "
                fi

                echo " $star ${dir##*/}"
            done
            ;;
        system) chruby_reset ;;
        *)
            local dir match
            for dir in "${RUBIES[@]}"; do
                dir="${dir%%/}"
                case "${dir##*/}" in
                    "$1")match="$dir" && break ;;
                    *"$1"*)match="$dir" ;;
                esac
            done

            if [[ -z "$match" ]]; then
                local no_match="chruby: unknown Ruby: $1"
                echo "\n  $(dull_red $no_match)\n" >&2
                return 1
            fi

            shift
            chruby_use "$match" "$*"
            ;;
    esac
}

# auto.sh
unset RUBY_AUTO_VERSION

function chruby_auto() {
    local dir="$PWD/" version

    until [[ -z "$dir" ]]; do
        dir="${dir%/*}"

        if { read -r version <"$dir/.ruby-version"; } 2>/dev/null || [[ -n "$version" ]]; then
            if [[ "$version" == "$RUBY_AUTO_VERSION" ]]; then return
            else
                RUBY_AUTO_VERSION="$version"
                echo "found ruby version $(hot_magenta $version)"
                chruby "$version"
                return $?
            fi
        fi
    done

    if [[ -n "$RUBY_AUTO_VERSION" ]]; then
        chruby_reset
        unset RUBY_AUTO_VERSION
    fi
}

if [[ -n "$ZSH_VERSION" ]]; then
    if [[ ! "$preexec_functions" == *chruby_auto* ]]; then
        preexec_functions+=("chruby_auto")
    fi
elif [[ -n "$BASH_VERSION" ]]; then
    trap '[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] && chruby_auto' DEBUG
fi

# gem_home.sh
function gem_home_push()
{
    mkdir -p "$1" && pushd "$1" >/dev/null || return 1
    local ruby_engine ruby_version gem_dir

    eval "$(ruby - <<EOF
puts "ruby_engine=#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'};"
puts "ruby_version=#{RUBY_VERSION};"
EOF
)"
    gem_dir="$PWD/.gem/$ruby_engine/$ruby_version"

    [[ "$GEM_HOME" == "$gem_dir" ]] && return

    export GEM_HOME="$gem_dir"
    export GEM_PATH="$gem_dir${GEM_PATH:+:}$GEM_PATH"
    export PATH="$gem_dir/bin${PATH:+:}$PATH"

    popd >/dev/null
    }

function gem_home_pop()
{
    local gem_dir="${GEM_PATH%%:*}"

    PATH=":$PATH:"
    GEM_PATH=":$GEM_PATH:"

    PATH="${PATH//:$gem_dir\/bin:/:}"
    GEM_PATH="${GEM_PATH//:$gem_dir:/:}"

    PATH="${PATH#:}"; PATH="${PATH%:}"
    GEM_PATH="${GEM_PATH#:}"; GEM_PATH="${GEM_PATH%:}"

    GEM_HOME="${GEM_PATH%%:*}"
    }

function gem_home()
{
    local ruby_engine ruby_version ruby_api_version gem_dir
    local version="0.0.1"

    case "$1" in
        -V|--version)echo "gem_home: $version" ;;
        -h|--help)
            cat <<USAGE
usage: gem_home [OPTIONS] [DIR|-]

Options:
-V, --versionPrints the version
-h, --helpPrints this message

Argumens:
DIRSets DIR as the new \$GEM_HOME
-Reverts to the previous \$GEM_HOME

Examples:

$ gem_home path/to/project
$ gem_home -
$ gem_home --vendor

USAGE

            ;;
        "")
            [[ -z "$GEM_PATH" ]] && return

            local gem_path="$GEM_PATH:"

            until [[ -z "$gem_path" ]]; do
                gem_dir="${gem_path%%:*}"

                if [[ "$gem_dir" == "$GEM_HOME" ]]; then
                    echo " * $gem_dir"
                else
                    echo "   $gem_dir"
                fi

                gem_path="${gem_path#*:}"
            done
            ;;
        -)
            gem_home_pop
            ;;
        *)
            gem_home_push "$1"
            ;;
    esac
}

reset_paths
