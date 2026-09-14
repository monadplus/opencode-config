# OpenCode configuration

- Usage: `$ opencode stats --days 90 --models`

## Install

```sh
sh ./install.sh
```

The installer links the configuration into `${XDG_CONFIG_HOME:-$HOME/.config}/opencode`. 

Authenticate separately on each machine with `/connect` or environment
variables. Do not commit `auth.json`, `node_modules`, `bun.lock`, databases, or
other generated state.

## Run server-client mode

```sh
# Server
export OPENCODE_SERVER_PASSWORD="..."
opencode serve --hostname 127.0.0.1 --port 4096

# Client
export OPENCODE_SERVER_PASSWORD="..."
# Use --dir <dir> to start in another directory
opencode attach http://127.0.0.1:4096

# Permission monitor
bash "$HOME/opencode-config/scripts/opencode-permission-monitor.sh" \
  --url http://127.0.0.1:4096 \
  --log "$HOME/.local/state/opencode/permission-monitor.md" \
  --state "$HOME/.local/state/opencode/permission-monitor.seen"
```

## macOS background services (launchd)

Run the server and permission monitor as separate services that start at login
and restart after exit. Requires `opencode` and `jq` on PATH.

### Prepare

After installing the configuration above, generate the LaunchAgents:

```sh
bash ./scripts/install-launchd.sh
```

Set `OPENCODE_SERVER_PASSWORD='your-password'` in the shared, Git-ignored env file:

```sh
env_file="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/launchd.env"
(umask 077; touch "$env_file")
chmod 600 "$env_file"
${EDITOR:-vi} "$env_file"
```

Put any required provider environment variables there too; shell startup files
are not loaded.

### Start and attach

Stop any manually running server and monitor, then load both services:

```sh
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.opencode.server.plist"
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.opencode.permission-monitor.plist"

# Attach from your project directory
export OPENCODE_SERVER_PASSWORD='replace-with-your-password'
opencode attach http://127.0.0.1:4096 --dir "$PWD"
```

### Manage

```sh
# Restart
launchctl kickstart -k "gui/$(id -u)/com.opencode.server"
launchctl kickstart -k "gui/$(id -u)/com.opencode.permission-monitor"

# Status
launchctl print "gui/$(id -u)/com.opencode.server"
launchctl print "gui/$(id -u)/com.opencode.permission-monitor"

# Stop until next login (use bootstrap to start again now)
launchctl bootout "gui/$(id -u)/com.opencode.permission-monitor"
launchctl bootout "gui/$(id -u)/com.opencode.server"
```

- **Logs:** `~/Library/Logs/opencode/`; decisions in `${XDG_STATE_HOME:-$HOME/.local/state}/opencode/permission-monitor.md`.
- **Changed checkout or executable paths:** rerun the installer, then `bootout` and `bootstrap` both jobs.
- **Uninstall:** stop both jobs and delete their `com.opencode.*.plist` files from `~/Library/LaunchAgents/`.

## Permission monitor

Preview:

```sh
bash "$HOME/opencode-config/scripts/opencode-permission-monitor.sh" \
  --url http://127.0.0.1:4096 \
  --include-session-history \
  --log "$HOME/.local/state/opencode/permission-monitor.md" \
  --state "$HOME/.local/state/opencode/permission-monitor.seen" \
  --once \
  --dry-run
```

**Policy:** replies `always` unless regex checks detect destructive commands or
secret access. This can approve Git and remote-action prompts configured as
`ask`; the checks are heuristics, not a complete security boundary.

- Logs and answered IDs live in `${XDG_STATE_HOME:-$HOME/.local/state}/opencode/`.
  Logs include best-effort redaction and candidate rules for manual review.
  Failed replies are retried; restart to begin a new day's log.
