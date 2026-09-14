#!/bin/sh
set -eu

home=${HOME:?HOME must be set}
project_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$home/.config"}
config_dir="$config_home/opencode"
backup_dir="$config_home/opencode-backup-$(date +%Y%m%d%H%M%S)-$$"
backup_ready=0

if command -v bun >/dev/null 2>&1; then
    package_manager=bun
elif command -v npm >/dev/null 2>&1; then
    package_manager=npm
else
    printf 'error: Install Bun or npm to install dependencies, then rerun this script.\n' >&2
    exit 1
fi

mkdir -p "$config_dir" "$config_dir/themes" "$config_dir/opencode-quota"

backup_existing() {
    target_path=$1

    if [ "$backup_ready" -eq 0 ]; then
        mkdir -p "$backup_dir"
        backup_ready=1
    fi

    backup_path="$backup_dir/$(basename "$target_path")"
    mv "$target_path" "$backup_path"
    printf 'Backed up %s to %s\n' "$target_path" "$backup_path"
}

link_path() {
    source_path=$1
    target_path=$2

    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
        return
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup_existing "$target_path"
    fi

    ln -s "$source_path" "$target_path"
    printf 'Linked %s -> %s\n' "$target_path" "$source_path"
}

link_path "$project_dir/opencode.jsonc" "$config_dir/opencode.jsonc"
link_path "$project_dir/tui.jsonc" "$config_dir/tui.jsonc"
link_path "$project_dir/primary-context.md" "$config_dir/primary-context.md"
link_path "$project_dir/package.json" "$config_dir/package.json"
link_path "$project_dir/agents" "$config_dir/agents"
link_path "$project_dir/commands" "$config_dir/commands"
link_path "$project_dir/plugins" "$config_dir/plugins"
link_path "$project_dir/skills" "$config_dir/skills"
link_path "$project_dir/scripts" "$config_dir/scripts"
link_path "$project_dir/themes/dracula.json" "$config_dir/themes/dracula.json"
link_path "$project_dir/quota-toast.jsonc" "$config_dir/opencode-quota/quota-toast.jsonc"

printf 'Installing OpenCode dependencies with %s in %s\n' "$package_manager" "$config_dir"
(
    cd "$config_dir"
    "$package_manager" install
)

printf '\nOpenCode configuration installed in %s\n' "$config_dir"
printf 'Restart OpenCode before using the new configuration.\n'
