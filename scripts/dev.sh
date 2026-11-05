#!/usr/bin/env bash
# Ambiente de desenvolvimento em container. Usa podman e, se não houver, docker.
#
# Uso:
#   scripts/dev.sh build            constrói a imagem
#   scripts/dev.sh shell            abre um shell com o repositório montado
#   scripts/dev.sh run <comando>    roda um comando dentro do container

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

IMAGE="${SYSMETRICS_DEV_IMAGE:-sysmetrics-collector-dev}"

if command -v podman >/dev/null 2>&1; then
    engine=podman
    user_args=(--userns=keep-id)
elif command -v docker >/dev/null 2>&1; then
    engine=docker
    user_args=(--user "$(id -u):$(id -g)")
else
    echo "Erro: instale podman ou docker." >&2
    exit 1
fi

run_in_container() {
    local tty_args=()
    [[ -t 0 && -t 1 ]] && tty_args=(-it)
    "$engine" run --rm "${tty_args[@]}" "${user_args[@]}" \
        -e HOME=/tmp \
        -v "${PWD}:/workspace:Z" \
        "$IMAGE" "$@"
}

case "${1:-}" in
build)
    "$engine" build -t "$IMAGE" -f containers/Containerfile .
    ;;
shell)
    run_in_container bash
    ;;
run)
    shift
    (($# > 0)) || {
        echo "Uso: $0 run <comando>" >&2
        exit 2
    }
    run_in_container "$@"
    ;;
*)
    sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
