
export Z_IGNORE_DIRS="$HOME/.gem:$HOME/.rubies:$HOME/Library"

function prune_z() {
    for dir in $(echo $Z_IGNORE_DIRS | tr ':' '\n'); do
        escaped_dir=$(echo $dir | sed 's/\//\\\//g')
        sed -i.bak "/$escaped_dir/d" ~/.z
    done
    rm ~/.z.bak
}
