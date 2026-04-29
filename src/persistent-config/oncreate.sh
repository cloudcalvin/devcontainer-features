#!/bin/sh

set -e

SCOPE="${SCOPE:-${scope:-workspace}}"
DIRS="${DIRS:-${dirs:-}}"

if [ "${SCOPE}" = "workspace" ]; then
    STORAGE_ROOT="/workspace"
else
    STORAGE_ROOT="/mnt/persistent-config-user-root"
fi

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n "$@"
    else
        return 1
    fi
}

fix_storage_permissions() {
    path="$1"
    [ -e "$path" ] || return 0
    TARGET_USER="$(id -un)"
    TARGET_GROUP="$(id -gn)"
    run_as_root chown -R "${TARGET_USER}:${TARGET_GROUP}" "$path" 2>/dev/null || true
    run_as_root chmod -R u+rwX "$path" 2>/dev/null || true
}

backup_path() {
    path="$1"
    backup="${path}.persistent-config-backup-$(date +%Y%m%d%H%M%S)"
    mv "$path" "$backup"
    echo "Moved existing non-symlink: $path -> $backup"
}

is_safe_relative_path() {
    path="$1"

    case "$path" in
        ""|/*|".."|../*|*/..|*"//"*|*"/../"*|*"~"*|*":"*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

setup_symlink() {
    dest="$1"
    src="${STORAGE_ROOT}/${dest}"
    target="${HOME}/${dest}"

    mkdir -p "$src"
    mkdir -p "$(dirname "$target")"
    fix_storage_permissions "$src"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        backup_path "$target"
    fi

    ln -s "$src" "$target"
    echo "Symlinked: ${dest}"
}

if [ "${SCOPE}" = "user" ]; then
    fix_storage_permissions "$STORAGE_ROOT"
fi

NORMALIZED_DIRS="$(printf '%s\n' "$DIRS" | tr ',;' '  ')"

for dest in $NORMALIZED_DIRS; do
    if ! is_safe_relative_path "$dest"; then
        echo "Invalid persisted directory: ${dest}" >&2
        exit 1
    fi

    setup_symlink "$dest"
done
