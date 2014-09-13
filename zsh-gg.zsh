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
