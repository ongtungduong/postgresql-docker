#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="${SCRIPT_DIR}/.env"
readonly PASSWORD_LENGTH=32

# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------

usage() {
    echo "Usage: $(basename "$0") <project_user>"
    echo "Generate .env with secure passwords and available ports."
    exit 1
}

generate_password() {
    openssl rand -base64 48 \
        | tr -d 'iI1lLoO0/+=\n' \
        | head -c "${PASSWORD_LENGTH}"
}

find_available_port() {
    local port="${1:?port argument required}"
    local max_port=$((port + 100))

    while [[ ${port} -le ${max_port} ]]; do
        if command -v ss &>/dev/null; then
            if ! ss -tlnH "sport = :${port}" | grep -q .; then
                echo "${port}"; return 0
            fi
        else
            # macOS fallback
            if ! lsof -iTCP:"${port}" -sTCP:LISTEN -P -n &>/dev/null; then
                echo "${port}"; return 0
            fi
        fi
        ((port++))
    done

    echo "Error: no available port in range ${1}–${max_port}" >&2
    return 1
}

get_shm_size_gb() {
    local total_ram_gb
if [[ "$(uname)" == "Darwin" ]]; then
    total_ram_gb=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1 / 1073741824}')
else
    total_ram_gb=$(awk '/MemTotal/ {printf "%.0f", $2 / 1048576}' /proc/meminfo)
fi
echo "${total_ram_gb}" | awk '{v = $1 * 0.3; r = int(v + 0.5); if (r < 1) r = 1; print r}'
}

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------

[[ $# -eq 1 ]] || usage

readonly PROJECT_USER="$1"

if [[ ! "${PROJECT_USER}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "Error: Invalid user '${PROJECT_USER}' (must match [a-zA-Z][a-zA-Z0-9_]*)." >&2
    exit 1
fi

if [[ -f "${ENV_FILE}" ]]; then
    read -rp ".env already exists. Overwrite? [y/N] " confirm
    [[ "${confirm}" =~ ^[yY]$ ]] || { echo "Aborted."; exit 0; }
fi

POSTGRES_PORT=$(find_available_port 5432)
EXPORTER_PORT=$(find_available_port "1${POSTGRES_PORT}")
SHM_SIZE="$(get_shm_size_gb)gb"

cat > "${ENV_FILE}" <<EOF
PROJECT_USER=${PROJECT_USER}
PROJECT_PASSWORD=$(generate_password)
POSTGRES_PASSWORD=$(generate_password)
EXPORTER_PASSWORD=$(generate_password)
POSTGRES_PORT=${POSTGRES_PORT}
EXPORTER_PORT=${EXPORTER_PORT}
POSTGRES_SHM_SIZE=${SHM_SIZE}
EOF

chmod 600 "${ENV_FILE}"
echo "${ENV_FILE} generated (pg=${POSTGRES_PORT}, exporter=${EXPORTER_PORT}, shm=${SHM_SIZE})"