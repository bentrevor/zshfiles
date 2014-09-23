export GEM_GROUP_AUTOSWITCH=true

### Gem Groups ###
function gg() {
    case "$1" in
        help | -h | --help)
            echo "Usage:"
            echo "\tlist\t\tlist all gem groups"
            echo "\tremove\tremove gem group"
            echo "\tdir\t\tshow $GEM_GROUP_DIR"
            echo "\treset\t\tuse null gem group"
            echo "\tcd\t\tchange to gem group dir"
            ;;

        list | -l)
            if [ -d $(gem_group_dir) ]; then
                echo "\n  gem groups for $(current_ruby):"
                ls -l "$(gem_group_dir)" | sed 's/.* /    /' | tail -n +2
                echo ''
            else
                echo "\n  no gem groups exist for $(current_ruby)\n"
            fi
            ;;

        reset)
            unset GEM_GROUP
            set_ruby_env
            ;;

        remove)
            current=$(basename $(pwd))
            rm -rf $(gem_group_dir)/$current
            echo "removed gem group $(dull_red $current)"
            ;;

        dir)
            echo $(gem_group_dir)
            ;;

        cd)
            # don't want to autoswitch gg
            old_gga=$GEM_GROUP_AUTOSWITCH
            GEM_GROUP_AUTOSWITCH=false
            cd $(gem_group_dir)/$GEM_GROUP/gems
            GEM_GROUP_AUTOSWITCH=$old_gga
            ;;

        on)
            GEM_GROUP_AUTOSWITCH=true
            ;;

        off)
            GEM_GROUP_AUTOSWITCH=false
            ;;

        "")
            if [[ -e ./Gemfile ]] && [[ -d ./.git ]]; then
                local new_gem_group=$(basename $(pwd))
                local new_gem_home=$(gem_group_dir)/$new_gem_group

                if [ ! -d $new_gem_home ]; then
                    echo "creating gem group $(dull_red $new_gem_group)"
                    mkdir -p ${new_gem_home}
                fi

                export GEM_HOME=${new_gem_home}
                export GEM_GROUP=${new_gem_group}

                echo "now using gem group $(dull_red $GEM_GROUP)"
            else
                echo "$(dull_red 'must be in root dir of ruby project')"
            fi
            ;;

        *)
            echo "unknown option $(dull_red $1)"
            ;;
    esac
}

function gg_auto() {
    if in_ruby_project; then
        local new_gem_group=$(basename $(pwd))
        local new_gem_home=$(gem_group_dir)/$new_gem_group

        if [ ! -d $new_gem_home ]; then
            echo "create gem group $(dull_red $new_gem_group) by running $(tput bold)$(hot_white 'gg')$(tput sgr0)"
            # don't want to still use previous group
            echo "\$ gg reset"
            gg reset
        else
            echo "\$ gg"
            gg
        fi
    elif [[ -n $GEM_GROUP ]]; then
        echo "\$ gg reset"
        gg reset
    fi
}

function gem_group_dir() {
    echo "/Users/ben/.gem/$(current_ruby)/groups"
}

function bundle_config_warning() {
    [ $(pwd) != $HOME ] && [ -d ./.bundle ] && echo "\n  $(dull_red 'WARNING: there is a project-specific bundler configuration\n  in .bundle, and it is probably going to screw shit up')\n"
}

### Helper functions ###
function current_ruby() {
    echo $(basename $RUBY_ROOT)
}

function set_ruby_env() {
    set_gem_home
    set_gem_path

    export PATH=$(gem_bins):$(ruby_bins):$(global_bins)
}

function set_gem_home() {
    if [[ -n $GEM_GROUP ]]; then
        export GEM_HOME=$(gem_group_dir)/$GEM_GROUP
    else
        export GEM_HOME=$RUBY_ROOT
    fi
}

function set_gem_path() { export GEM_PATH=$RUBY_ROOT:$GEM_ROOT:$GEM_HOME }

function global_bins()  { echo '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }
function ruby_bins()    { echo "$RUBY_ROOT/bin" }
function gem_bins()     { echo "$GEM_HOME/bin" }


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
