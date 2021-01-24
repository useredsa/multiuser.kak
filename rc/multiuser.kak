# This module provides a framework for handling multiple users in kakoune
# Each client can be associated a user in a relation 0:1 - 1:n.
# Other plugins can listen to the user hooks
# `RegisterUser`
# `SetUserWindowOptions`
# `RemoveUserWindowOptions`
# to define options for a specific user.
# Each client will have its user options defined in every window
# thanks to the `SetUserWindowOptions` hook.
# Commands can also access the option user to act depending on the current user.
provide-module multiuser %{

declare-option -docstring %{
    This client's username (multiuser.kak)
} str user

declare-option -hidden -docstring %{
    User associated to each client
} str-to-str-map client_to_user

define-command -override -docstring %{
    set-user: Set the client's user
    Before setting the client it triggers the hook RemoveUserWindowOptions
    Afterwards it triggers the hooks RegisterUser and SetUserWindowOptions
} set-user -params 1 %{
    trigger-user-hook RemoveUserWindowOptions
    set-option window user %arg{1}
    set-option -add global client_to_user "%val{client}=%arg{1}"
    trigger-user-hook RegisterUser
    trigger-user-hook SetUserWindowOptions
}

# Sets the user option in each window of a client
hook -group multiuser global WinDisplay '.*' %{
    eval %sh{
        eval set -- $kak_quoted_opt_client_to_user
        for entry; do
            printf %s\\n "echo -debug %{$entry}"
            case "$entry" in
                "$kak_client"=*)
                    printf %s\\n "set-option window user ${entry#*=}"
                    printf %s\\n "trigger-user-hook SetUserWindowOptions"
                    return
                    ;;
            esac
        done
    }
}

}
