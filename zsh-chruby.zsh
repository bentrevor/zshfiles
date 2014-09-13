# chruby.sh and auto.sh with more verbose output
# (from https://github.com/postmodern/chruby)
CHRUBY_VERSION="0.3.8"

RUBIES=()
for dir in "$PREFIX/opt/rubies" "$HOME/.rubies"; do
    [[ -d "$dir" && -n "$(ls -A "$dir")" ]] && RUBIES+=("$dir"/*)
done
unset dir

function chruby_reset() {
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
                local no_match="$1 is not installed"
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
                echo "found ruby version $(dull_red $version)"
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

[[ ! "$preexec_functions" == *chruby_auto* ]] && preexec_functions+=("chruby_auto")
