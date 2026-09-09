# OpenCode configuration

Standalone copy of the OpenCode configuration used on the source machine.
This project is intended to be published as a separate public GitHub
repository and cloned on another workstation.

## Install

Install OpenCode, clone this repository, and run:

```sh
sh ./install.sh
```

The installer links the configuration into
`${XDG_CONFIG_HOME:-$HOME/.config}/opencode`. It does not copy authentication
files or runtime state. Existing conflicting configuration entries are moved
to a timestamped backup directory beside the OpenCode config directory.

Authenticate separately on each machine with `/connect` or environment
variables. Do not commit `auth.json`, `node_modules`, `bun.lock`, databases, or
other generated state.

Restart OpenCode after installation or configuration changes.
