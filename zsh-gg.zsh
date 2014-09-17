export GEM_GROUP_DIR=~/.gem/groups
mkdir -p $GEM_GROUP_DIR

### Gem Groups ###
function gg() {
    local new_gem_group=$(basename $(pwd))
    local new_gem_home=$GEM_GROUP_DIR/$new_gem_group

    case "$1" in
        help | -h | --help)
            echo "Usage:"
            echo "\tlist\t\tlist all gem groups"
            echo "\tremove\tremove gem group"
            echo "\tdir\t\tshow $GEM_GROUP_DIR"
            echo "\treset\t\tuse null gem group"
            ;;

        list | -l)
            echo '\n  gem groups:'
            ls -l $GEM_GROUP_DIR | sed 's/.* /    /' | tail -n +2
            echo ''
            ;;

        reset)
            unset GEM_GROUP
            set_ruby_env
            ;;

        remove)
            current=$(basename $(pwd))
            rm -rf $GEM_GROUP_DIR/$current
            echo "removed gem group $(dull_red $current)"
            ;;

        dir)
            echo $GEM_GROUP_DIR
            ;;

        "")
            if ! in_ruby_project; then
                echo 'must be in ruby project'
            else
                if [ ! -d $new_gem_home ]; then
                    echo "creating new gem group $(dull_red $new_gem_group)"
                    mkdir -p ${new_gem_home}
                fi

                export GEM_HOME=${new_gem_home}
                export GEM_GROUP=${new_gem_group}

                echo "now using gem group $(dull_red $GEM_GROUP)"
            fi
            ;;
    esac
}

function gg_auto() {
    if in_ruby_project; then
        echo "\$ gg"
        gg
    else
        echo "\$ gg reset"
        gg reset
    fi
}

export GEM_GROUP_AUTOSWITCH=true

function chpwd() {
    chruby_auto
    [ $GEM_GROUP_AUTOSWITCH = true ] && gg_auto
    set_ruby_env
}

### Helper functions ###
function set_ruby_env() {
    set_gem_home
    set_gem_path

    export PATH=$(gem_bins):$(ruby_bins):$(global_bins)
}

function set_gem_home() {
    if [[ -n $GEM_GROUP ]]; then
        export GEM_HOME=$GEM_GROUP_DIR/$GEM_GROUP
    else
        export GEM_HOME=$RUBY_ROOT
    fi
}

function set_gem_path()  { export GEM_PATH=$RUBY_ROOT }

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
function in_ruby_project() { find_gemfile && find_git_dir }

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
