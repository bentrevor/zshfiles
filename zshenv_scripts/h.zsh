
function h() {
    help_message=''
    case "$1" in
        git)
            case "$2" in
                stash)
                    help_message="save stash with a message:\n  git stash save <msg>\n\n"
                    ;;
            esac
            ;;
        *)
            help_message="\n\nunknown arg: $(dull_cyan $1)\n\n"
            ;;
    esac
}
