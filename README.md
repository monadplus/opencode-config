# OpenCode configuration

## Install

```sh
sh ./install.sh
```

Authenticate separately on each machine with `/connect`.

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

## Background services

- [macOS (launchd)](macos/launchd/README.md)
- [Linux (systemd)](linux/systemd/README.md)

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

## Tips & Tricks

- Usage: `$ opencode stats --days 90 --models`
