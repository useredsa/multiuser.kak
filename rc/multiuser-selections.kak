provide-module multiuser-selections %{

require-module multiuser

declare-option -docstring %{
    default face format used for highlightning other users selections
} str user_selections_default_facefmt "default,rgba:AAFFAA30"

declare-option -docstring %{
    default face format used for highlighting other users cursors
} str user_cursors_default_facefmt "default,rgba:AAFFAA40"

define-command -hidden -docstring %{
    store-user-selections: stores the user current selections
} store-user-selections %{
    eval -draft -save-regs ^ %{
        exec -save-regs '' Z
        set global "%opt{user}_selections" %reg{^}
    }
    set buffer "%opt{user}_selections_ranges" %val{timestamp}
    set buffer "%opt{user}_cursors_ranges" %val{timestamp}
    eval -no-hooks -draft -itersel %{
        set -add buffer "%opt{user}_selections_ranges" "%val{selection_desc}|%opt{user}Selections"
        exec '<space>;'
        set -add buffer "%opt{user}_cursors_ranges" "%val{selection_desc}|%opt{user}Cursors"
    }
}

hook -group multiuser-selections global RawKey '.*' %{
    try store-user-selections
}

define-command -docstring %{
    goto-user [<user>]: Jumps to the user <user>'s location.
    If no user is provided, the first other user found is used instead,
    which is useful if the session is only shared by two users.
} -override goto-user -params 0..1 %{
    eval -save-regs ^ %sh{
        other_user() {
            key="$1"
            shift
            eval set -- "$@"
            for entry; do
                case "$entry" in
                    *="$key")
                        ;;
                    *)
                        user="${entry#*=}"
                        return
                esac
            done
            printf "fail 'No other user found'\n"
        }

        user="$1"
        if [ -z "$user" ]; then
            other_user $kak_opt_user $kak_quoted_opt_client_to_user
        fi
        printf %s\\n "reg ^ %opt{${user}_selections}"
    } %{
        exec -save-regs '' z
        echo "Copied user %arg{1} selections"
    }
}

hook -group multiuser-selections global User RegisterUser %{
    # User selections description allows jumping to another users location
    declare-option -hidden str-list "%opt{user}_selections"
    # Selections and cursors ranges allow highlightning
    declare-option -hidden range-specs "%opt{user}_selections_ranges"
    declare-option -hidden range-specs "%opt{user}_cursors_ranges"
    face global "%opt{user}Selections" "%opt{user_selections_default_facefmt}"
    face global "%opt{user}Cursors" "%opt{user_cursors_default_facefmt}"
    add-highlighter -override "global/%opt{user}_selections_ranges" ranges "%opt{user}_selections_ranges"
    add-highlighter -override "global/%opt{user}_cursors_ranges" ranges "%opt{user}_cursors_ranges"
}

hook -group multiuser-selections global User SetUserWindowOptions %{
    face window "%opt{user}Selections" default
    face window "%opt{user}Cursors" default
}

hook -group multiuser-selections global User RemoveUserWindowOptions %{
    unset-face window "%opt{user}Selections"
    unset-face window "%opt{user}Cursors"
}

}
