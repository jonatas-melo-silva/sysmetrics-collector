# shellcheck shell=bash
# Funções compartilhadas pelos testes bats.

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${TESTS_DIR}/.." && pwd)"
# shellcheck disable=SC2034
BIN="${PROJECT_DIR}/bin/sysmetrics-collector"

setup_env() {
    ORIGINAL_PATH="$PATH"
    TEST_TMP="$(mktemp -d)"
    export SYSMETRICS_ROOT="$PROJECT_DIR"
    export SYSMETRICS_LOG_DIR="${TEST_TMP}/logs"
    export HOME="${TEST_TMP}/home"
    export NO_COLOR=1
    unset SYSMETRICS_INTERVAL SYSMETRICS_MAX_DAYS SYSMETRICS_LANG SYSMETRICS_TOP_PROCS STUB_SENSORS_FAIL
    mkdir -p "$HOME"
}

teardown_env() {
    export PATH="$ORIGINAL_PATH"
    rm -rf "$TEST_TMP"
}

# Carrega módulos de src/ pelo nome relativo, sem extensão (ex.: utils/logger).
load_modules() {
    local module
    for module in "$@"; do
        # shellcheck disable=SC1090
        source "${PROJECT_DIR}/src/${module}.sh"
    done
}

# Comandos de métricas falsos na frente do PATH.
use_stubs() {
    export PATH="${TESTS_DIR}/stubs:${PATH}"
}

# PATH isolado: só os stubs (menos os listados em "$@") e os utilitários básicos.
# Serve para simular a ausência de um comando, mesmo que ele exista na máquina.
isolated_path() {
    local dir="${TEST_TMP}/isolated" skip=" $* " file cmd
    mkdir -p "$dir"
    for file in "${TESTS_DIR}"/stubs/*; do
        cmd="$(basename "$file")"
        [[ "$skip" == *" ${cmd} "* ]] || ln -s "$file" "${dir}/${cmd}"
    done
    for cmd in bash date mkdir sed grep find sort touch cat dirname readlink tr rm sleep kill awk jq nproc who tail; do
        [[ "$skip" == *" ${cmd} "* ]] || ln -s "$(command -v "$cmd")" "${dir}/${cmd}"
    done
    export PATH="$dir"
}
