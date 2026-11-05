#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules config/settings core/retention
    mkdir -p "$SYSMETRICS_LOG_DIR"
}
teardown() { teardown_env; }

@test "apaga relatórios mais velhos que a retenção e mantém os recentes" {
    touch -d "8 days ago" "${SYSMETRICS_LOG_DIR}/system_velho.log"
    touch -d "6 days ago" "${SYSMETRICS_LOG_DIR}/system_recente.log"
    run cleanup_old_logs
    [ "$status" -eq 0 ]
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_velho.log" ]
    [ -e "${SYSMETRICS_LOG_DIR}/system_recente.log" ]
}

@test "respeita SYSMETRICS_MAX_DAYS" {
    SYSMETRICS_MAX_DAYS=2
    touch -d "3 days ago" "${SYSMETRICS_LOG_DIR}/system_a.log"
    touch -d "1 day ago" "${SYSMETRICS_LOG_DIR}/system_b.log"
    cleanup_old_logs
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_a.log" ]
    [ -e "${SYSMETRICS_LOG_DIR}/system_b.log" ]
}

@test "não toca em arquivos que não são relatórios" {
    touch -d "30 days ago" "${SYSMETRICS_LOG_DIR}/notas.txt" "${SYSMETRICS_LOG_DIR}/outro.log"
    cleanup_old_logs
    [ -e "${SYSMETRICS_LOG_DIR}/notas.txt" ]
    [ -e "${SYSMETRICS_LOG_DIR}/outro.log" ]
}

@test "não falha quando o diretório ainda não existe" {
    SYSMETRICS_LOG_DIR="${TEST_TMP}/nao-existe"
    run cleanup_old_logs
    [ "$status" -eq 0 ]
}
