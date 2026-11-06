#!/usr/bin/env bash
# Instala as dependências do sysmetrics-collector (Debian, Ubuntu e derivados).
# Uso: sudo scripts/install-deps.sh [--configure-sensors]
#
# --configure-sensors roda o sensors-detect em modo automático. Ele carrega
# módulos do kernel, por isso não é feito por padrão.

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Execute como root: sudo $0" >&2
    exit 1
fi

packages=(lm-sensors procps coreutils util-linux findutils gawk jq)

apt-get update
apt-get install -y --no-install-recommends "${packages[@]}"

if [[ "${1:-}" == "--configure-sensors" ]]; then
    sensors-detect --auto
fi
