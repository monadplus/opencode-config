#!/bin/bash
# Generate user LaunchAgents; loading/restarting them is an explicit separate step.
set -eu

[[ "$(uname -s)" == Darwin ]] || { printf 'This installer requires macOS.\n' >&2; exit 1; }
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
AGENT_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs/opencode"
ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/launchd.env"
OPENCODE_BIN="$(command -v opencode)" || { printf 'opencode is required on PATH.\n' >&2; exit 1; }
command -v jq >/dev/null || { printf 'jq is required on PATH.\n' >&2; exit 1; }
[[ "$OPENCODE_BIN" == /* && "$PATH" != :* && "$PATH" != *: && "$PATH" != *::* ]] || {
    printf 'Use an absolute OpenCode executable and a PATH without empty entries.\n' >&2
    exit 1
}
IFS=: read -r -a path_entries <<< "$PATH"
for entry in "${path_entries[@]}"; do
    [[ "$entry" == /* ]] || { printf 'PATH entries must be absolute: %s\n' "$entry" >&2; exit 1; }
done

xml_escape() {
    local value="$1"
    value="${value//&/&amp;}"
    value="${value//</&lt;}"
    value="${value//>/&gt;}"
    printf '%s' "$value"
}

umask 077
mkdir -p "$AGENT_DIR" "$LOG_DIR"
for service in server permission-monitor; do
    label="com.opencode.$service"
    plist="$AGENT_DIR/$label.plist"
    # Refuse to replace a plist containing a different label.
    if [[ -e "$plist" ]]; then
        existing_label="$(/usr/libexec/PlistBuddy -c 'Print :Label' "$plist")"
        [[ "$existing_label" == "$label" ]] || { printf 'Unexpected label in %s\n' "$plist" >&2; exit 1; }
    fi
    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$(xml_escape "$SCRIPT_DIR/opencode-launchd.sh")</string>
        <string>$service</string>
        <string>$(xml_escape "$OPENCODE_BIN")</string>
    </array>
    <key>WorkingDirectory</key><string>$(xml_escape "$HOME")</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key><string>$(xml_escape "$PATH")</string>
        <key>OPENCODE_LAUNCHD_ENV</key><string>$(xml_escape "$ENV_FILE")</string>
        <key>XDG_CONFIG_HOME</key><string>$(xml_escape "${XDG_CONFIG_HOME:-$HOME/.config}")</string>
        <key>XDG_STATE_HOME</key><string>$(xml_escape "${XDG_STATE_HOME:-$HOME/.local/state}")</string>
    </dict>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>ThrottleInterval</key><integer>10</integer>
    <key>StandardOutPath</key><string>$(xml_escape "$LOG_DIR/$service.stdout.log")</string>
    <key>StandardErrorPath</key><string>$(xml_escape "$LOG_DIR/$service.stderr.log")</string>
</dict>
</plist>
EOF
    /usr/bin/plutil -lint "$plist"
done
printf 'LaunchAgents prepared in %s. See README.md to load them.\n' "$AGENT_DIR"
