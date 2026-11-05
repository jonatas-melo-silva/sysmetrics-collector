#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules config/settings utils/logger core/collector
}
teardown() { teardown_env; }

@test "o relatório tem todas as seções" {
    use_stubs
    run build_report
    [ "$status" -eq 0 ]
    for secao in "Informações de CPU" "Temperaturas" "Uso de Memória" \
        "Uptime e Carga do Sistema" "Uso de Disco" "Processos Mais Ativos"; do
        [[ "$output" == *"[${secao}]"* ]]
    done
}

@test "a seção de CPU mostra só modelo e frequência" {
    use_stubs
    run build_report
    [[ "$output" == *"Stub CPU 3000"* ]]
    [[ "$output" == *"3000.000"* ]]
    [[ "$output" != *"StubVendor"* ]]
}

@test "a seção de processos mostra o cabeçalho e os 5 primeiros" {
    use_stubs
    run build_report
    [ "$(grep -c stubproc <<<"$output")" -eq 5 ]
    [[ "$output" == *"stubproc5"* ]]
    [[ "$output" != *"stubproc6"* ]]
}

@test "sem o sensors o relatório sai completo, com temperatura indisponível" {
    isolated_path sensors
    run build_report
    [ "$status" -eq 0 ]
    [[ "$output" == *"indisponível (sensors não instalado)"* ]]
    [[ "$output" == *"[Uso de Disco]"* ]]
}

@test "falha do sensors vira texto no relatório em vez de abortar a coleta" {
    use_stubs
    export STUB_SENSORS_FAIL=1
    run build_report
    [ "$status" -eq 0 ]
    [[ "$output" == *"indisponível (falha ao executar: sensors)"* ]]
    [[ "$output" == *"[Uso de Memória]"* ]]
}

@test "collect_system_info cria o diretório e grava no arquivo do dia" {
    use_stubs
    run collect_system_info
    [ "$status" -eq 0 ]
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).log"
    [ -f "$arquivo" ]
    grep -q "Relatório do Sistema" "$arquivo"
}

@test "coletas seguidas acrescentam ao mesmo arquivo" {
    use_stubs
    collect_system_info
    collect_system_info
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).log"
    [ "$(grep -c "Relatório do Sistema" "$arquivo")" -eq 2 ]
}

@test "collect_system_info falha com erro claro se não consegue criar o diretório" {
    use_stubs
    touch "${TEST_TMP}/arquivo"
    SYSMETRICS_LOG_DIR="${TEST_TMP}/arquivo/dentro"
    run collect_system_info
    [ "$status" -eq 1 ]
    [[ "$output" == *"Não foi possível criar o diretório de logs"* ]]
}

@test "regressão: o arquivo de log acompanha a data (loop que atravessa a meia-noite)" {
    date() { echo 20991231; }
    [ "$(current_log_file)" = "${SYSMETRICS_LOG_DIR}/system_20991231.log" ]
    date() { echo 21000101; }
    [ "$(current_log_file)" = "${SYSMETRICS_LOG_DIR}/system_21000101.log" ]
}
