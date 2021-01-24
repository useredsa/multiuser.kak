# Multiuser: A Kakoune plugin that emulates a user scope

[Kakoune]'s client-server design lets
multiple clients connect to the same session and edit the same files.
This is specially useful for collaborative editing over the network.
However, Kakoune's model was thought so that a single user
would spawn multiple clients.
Thus, by default some features are missing.
This include

* Showing other users' selections.
* Separating the clipboard management for different clients
(and registers in general).
It is very annoying pasting something and realizing that
the yank register was overwritten by another user.
* Allowing different buffers for tools such as make.
* Allowing different mappings.
* And ultimately: managing permissions to run commands.
Using different users or restricting commands to some users.

This plugin intent is to create a base solution for
implementing that functionality.

[Kakoune]: https://kakoune.org

## List of Features

* [`multiuser`](rc/multiuser.kak):
The main module.
Allows associating each client with a user in a relation 0:1 - 1:n.
Other modules can listen to the user hooks
`RegisterUser`
`SetUserWindowOptions`
`RemoveUserWindowOptions`
to define options for a specific user.
Each client will have its options defined in every window
thanks to the `SetUserWindowOptions` hook.
Commands can also access the option user to act depending on the current user.

* [`multiuser-selections`](rc/multiuser-selections.kak):
Supports the highlighting of other users selections and
jumping to another user location.

## Installation

Source the scripts inside [`rc`] and require the modules on startup.

[`rc`]: rc/

### Using @alexherbo2's [`plug.kak`](https://github.com/alexherbo2/plug.kak)

```kak
plug bspwm https://github.com/useredsa/multiuser.kak %{
    require-module multiuser-selections
}
```

### Using @robertmeta's [`plug.kak`](https://github.com/robertmeta/plug.kak)

```kak
plug "useredsa/multiuser.kak" %{
    require-module multiuser-selections
}
```

### Example configuration

```kak
# Registers clients opened via SSH with their ip as username
# Normal clients are registered as main
hook -group multiuser global ClientCreate '.*' %{
    set-user %sh{
        user="$(echo $kak_client_env_SSH_CLIENT | tr . _ | cut -d' ' -f 1)"
        printf %s\\n "'${user:-main}'"
    }
}

# Allows quickly jumping to the location of another user
map -docstring 'user' global goto u '<a-;>: goto-user<ret>'
```
