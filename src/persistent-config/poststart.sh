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
    [ -e "${path}" ] || return 0
    TARGET_USER="$(id -un)"
    TARGET_GROUP="$(id -gn)"
    run_as_root chown -R "${TARGET_USER}:${TARGET_GROUP}" "${path}" 2>/dev/null || true
    run_as_root chmod -R u+rwX "${path}" 2>/dev/null || true
}

if [ "${SCOPE}" = "user" ]; then
    fix_storage_permissions "${STORAGE_ROOT}"
else
    NORMALIZED_DIRS="$(printf '%s\n' "$DIRS" | tr ',;' '  ')"
    for dest in $NORMALIZED_DIRS; do
        fix_storage_permissions "${STORAGE_ROOT}/${dest}"
    done
fi

NORMALIZED_DIRS="$(printf '%s\n' "$DIRS" | tr ',;' '  ')"
for dest in $NORMALIZED_DIRS; do
    if [ ! -w "${STORAGE_ROOT}/${dest}" ]; then
        echo "Warning: persistent-config storage is not writable: ${STORAGE_ROOT}/${dest}"
    fi
done
