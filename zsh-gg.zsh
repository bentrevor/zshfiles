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

function reset_paths() {
    set_gem_path
    set_gem_home

    export PATH=$(gem_bins):$(ruby_bins):$(global_bins)
}

function set_gem_path()  { export GEM_PATH=$RUBY_ROOT }

function set_gem_home() {
    if [[ -n $GEM_GROUP ]]; then
        export GEM_HOME=$GEM_GROUP_DIR/$GEM_GROUP
    else
        export GEM_HOME=$RUBY_ROOT
    fi
}

function global_bins() { echo '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }
function ruby_bins()   { echo "$RUBY_ROOT/bin" }
function gem_bins()    { echo "$GEM_HOME/bin" }


function find_file_in_parent_dirs() {
    local bool=false
    local dir="$PWD"

    until [[ -z "$dir" ]]; do
        if [[ -e "$dir/$1" ]]; then
            bool=true
        fi

        dir="${dir%/*}"
    done

    echo $bool
}

function find_gemfile()    { [[ $(find_file_in_parent_dirs 'Gemfile') = 'true' ]] }
function find_git_dir()    { [[ $(find_file_in_parent_dirs '.git') = 'true' ]] }
function in_ruby_project() { find_gemfile && find_git_dir && echo 'in ruby project' }
# ruby environment
function re() {
    echo ''
    echo "$(dull_red PATH:)"
    show-path
    echo ''
    echo "$(dull_red GEM_PATH) \t=>\t$GEM_PATH"
    echo "$(dull_red GEM_HOME) \t=>\t$GEM_HOME"
    echo "$(dull_red GEM_ROOT) \t=>\t$GEM_ROOT"
    echo "$(dull_red GEM_GROUP) \t=>\t$GEM_GROUP"
    echo "$(dull_red RUBY_ENGINE) \t=>\t$RUBY_ENGINE"
    echo "$(dull_red RUBY_ROOT) \t=>\t$RUBY_ROOT"
}


### Gem Groups ###
function gg() {
    export GEM_GROUP=$(basename $(pwd))

    local new_gem_home=$GEM_GROUP_DIR/$GEM_GROUP
    local printable_gem_path=$(echo $GEM_PATH | sed 's/:/\\n\\t\\t/g')

    changes="New $(dull_red \$GEM_HOME):\t$new_gem_home\n\n$(dull_red \$GEM_PATH):\t$printable_gem_path\n"

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
            echo "removing gem group $(dull_red $2)"
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
