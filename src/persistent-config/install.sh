#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/usr/local/share/persistent-config"
SCOPE_VALUE="${SCOPE:-${scope:-workspace}}"
DIRS_VALUE="${DIRS:-${dirs:-}}"

case "${SCOPE_VALUE}" in
    workspace|user)
        ;;
    *)
        echo "Invalid scope: ${SCOPE_VALUE}" >&2
        exit 1
        ;;
esac

case "${DIRS_VALUE}" in
    *'
'*)
        echo "Invalid dirs: newlines are not supported." >&2
        exit 1
        ;;
esac

shell_quote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

mkdir -p "${INSTALL_DIR}"

cp "${SCRIPT_DIR}/oncreate.sh" "${INSTALL_DIR}/oncreate.sh"
cp "${SCRIPT_DIR}/poststart.sh" "${INSTALL_DIR}/poststart.sh"
chmod +x "${INSTALL_DIR}/oncreate.sh"
chmod +x "${INSTALL_DIR}/poststart.sh"

{
    printf 'export SCOPE=%s\n' "$(shell_quote "${SCOPE_VALUE}")"
    printf 'export DIRS=%s\n' "$(shell_quote "${DIRS_VALUE}")"
} > "${INSTALL_DIR}/env"
