#!/bin/bash
# Foreground entry point shared by the two user LaunchAgents.
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ENV_FILE="${OPENCODE_LAUNCHD_ENV:-$HOME/.config/opencode/launchd.env}"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

case "${1:-}" in
    server)
        exec "${2:?Missing OpenCode executable}" serve --hostname 127.0.0.1 --port 4096
        ;;
    permission-monitor)
        exec /bin/bash "$SCRIPT_DIR/../../scripts/opencode-permission-monitor.sh" \
            --url http://127.0.0.1:4096 --quiet \
            --log "${XDG_STATE_HOME:-$HOME/.local/state}/opencode/permission-monitor.md"
        ;;
    *)
        printf 'Usage: %s {server <opencode executable>|permission-monitor}\n' "$0" >&2
        exit 64
        ;;
esac
