# Linux (systemd)

Copy the permission monitor script to the path used by its service. If you already
ran `sh ./install.sh` as described in the [installation instructions](../../README.md#install),
the `scripts` directory is linked there and you can skip this copy step:

```sh
scripts_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/scripts"
mkdir -p "$scripts_dir"
cp scripts/opencode-permission-monitor.sh "$scripts_dir/"
```

Copy the systemd units:

```sh
# Review the copied files before starting them. The server searches for `opencode`
# in `~/.opencode/bin`, `~/.bun/bin`, `~/.local/bin`, `/usr/local/bin`, and `/usr/bin`.
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$unit_dir"
cp linux/systemd/opencode-server.service linux/systemd/opencode-permission-monitor.service "$unit_dir/"
```

Create the shared, Git-ignored environment file:

```sh
env_file="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/systemd.env"
(umask 077; touch "$env_file")
chmod 600 "$env_file"
${EDITOR:-vi} "$env_file"
```

Set the password and any required provider environment variables:

```ini
export OPENCODE_SERVER_PASSWORD='your-password'
```

## Start and attach

Stop any manually running server and monitor, then enable both services:

```sh
systemctl --user daemon-reload
systemctl --user enable --now opencode-server.service opencode-permission-monitor.service

# Attach from your project directory
export OPENCODE_SERVER_PASSWORD='replace-with-your-password'
opencode attach http://127.0.0.1:4096 --dir "$PWD"
```

The monitor starts after the server process and retries while the API becomes
ready or the server restarts. To start at boot and keep running after logout,
optionally enable lingering:

```sh
loginctl enable-linger "$USER"
```

## Manage

```sh
# Restart (also needed after changing systemd.env)
systemctl --user restart opencode-server.service opencode-permission-monitor.service

# Status and logs
systemctl --user status opencode-server.service opencode-permission-monitor.service
journalctl --user -u opencode-server.service -u opencode-permission-monitor.service -f

# Stop until next login (use start to run again now)
systemctl --user stop opencode-permission-monitor.service opencode-server.service

# Disable automatic startup and stop
systemctl --user disable --now opencode-permission-monitor.service opencode-server.service
```

- **Decision logs and answered IDs:** `${XDG_STATE_HOME:-$HOME/.local/state}/opencode/permission-monitor.md` and `permission-monitor.seen`.
- **Changed monitor script:** if you copied it manually, repeat the script copy above and restart `opencode-permission-monitor.service`.
- **Changed units:** edit the installed copies (or copy updated files from `linux/systemd/`), run `systemctl --user daemon-reload`, then restart both services. If you move the checkout, update the configuration's script symlink by rerunning `sh ./install.sh`.
- **Uninstall:** disable and stop both services, delete `opencode-server.service` and `opencode-permission-monitor.service` from `${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/`, then run `systemctl --user daemon-reload`.
