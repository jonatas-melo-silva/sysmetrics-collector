#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules config/settings utils/logger core/schema core/collector
}
teardown() { teardown_env; }

@test "build_record gera uma única linha de JSON válido" {
    use_stubs
    local record
    record="$(build_record)"
    [ "$(wc -l <<<"$record")" -eq 1 ]
    jq -e . <<<"$record" >/dev/null
}

@test "em inglês (padrão) os campos têm nomes em inglês" {
    use_stubs
    build_record | jq -e '
        has("timestamp")
        and .cpu.mhz_max == 3000 and .cpu.mhz_min == 800 and has("temperatures_c")
        and .memory.ram.used_bytes == 4000000000
        and .memory.ram.available_bytes == 11000000000
        and .memory.swap.free_bytes == 1500000000
        and (.system.load.avg_1m | type == "number")
        and .disk[0].mount == "/" and .disk[0].used_pct == 10
        and .processes[0].command == "stubproc1"
        and (.processes[0] | has("cpu_time_s"))' >/dev/null
}

@test "em português os campos têm nomes em português" {
    use_stubs
    SYSMETRICS_LANG=pt
    build_record | jq -e '
        has("data_hora") and (has("timestamp") | not)
        and .cpu.mhz_max == 3000 and has("temperaturas_c")
        and .memoria.ram.usada_bytes == 4000000000
        and .memoria.ram.disponivel_bytes == 11000000000
        and .memoria.swap.livre_bytes == 1500000000
        and (.sistema.carga.media_1m | type == "number")
        and .disco[0].montagem == "/" and .disco[0].uso_pct == 10
        and .processos[0].comando == "stubproc1"
        and (.processos[0] | has("tempo_cpu_s"))' >/dev/null
}

@test "os dois idiomas têm o mesmo formato e os mesmos valores" {
    use_stubs
    local en pt
    en="$(build_record)"
    SYSMETRICS_LANG=pt
    pt="$(build_record)"
    # Compara só o que não muda entre duas coletas: memória, disco e processos.
    [ "$(jq -c '[.memory.ram[], .memory.swap[]]' <<<"$en")" = "$(jq -c '[.memoria.ram[], .memoria.swap[]]' <<<"$pt")" ]
    [ "$(jq -c '[.disk[0][]]' <<<"$en")" = "$(jq -c '[.disco[0][]]' <<<"$pt")" ]
    [ "$(jq -c '[.processes[] | [.[]]]' <<<"$en")" = "$(jq -c '[.processos[] | [.[]]]' <<<"$pt")" ]
    [ "$(jq '[paths] | length' <<<"$en")" -eq "$(jq '[paths] | length' <<<"$pt")" ]
}

@test "temperaturas: tira o acpitz e o Adapter" {
    use_stubs
    build_record | jq -e '.temperatures_c == {"coretemp-isa-0000": {"Package id 0": 42}}' >/dev/null
}

@test "processos: agrupa por comando, ordena pelo %CPU do top e limita ao TOP_PROCS" {
    use_stubs
    SYSMETRICS_TOP_PROCS=7
    build_record | jq -e '
        (.processes | length) == 7
        and .processes[0].command == "stubproc1"
        and .processes[6].command == "stubproc7"
        and .processes[6].count == 2
        and .processes[6].cpu_pct == 3.5
        and .processes[6].rss_kb == 200' >/dev/null
}

@test "a seção de processos respeita o padrão de 5 grupos" {
    use_stubs
    SYSMETRICS_TOP_PROCS=5
    [ "$(build_record | jq '.processes | length')" -eq 5 ]
}

@test "sem o sensors o registro sai completo, com temperaturas vazias" {
    isolated_path sensors
    local record
    record="$(build_record)"
    jq -e '.temperatures_c == {} and .memory.ram.total_bytes == 16000000000 and (.disk | length) == 1' <<<"$record" >/dev/null
}

@test "falha do sensors vira temperaturas vazias em vez de abortar a coleta" {
    use_stubs
    export STUB_SENSORS_FAIL=1
    build_record | jq -e '.temperatures_c == {} and (.processes | length) == 5' >/dev/null
}

@test "falha de um comando deixa só o campo dele vazio" {
    isolated_path free
    SYSMETRICS_LANG=pt
    build_record | jq -e '
        .memoria.ram.usada_bytes == null
        and .disco[0].montagem == "/"
        and (.processos | length) == 5' >/dev/null
}

@test "collect_system_info em inglês grava em system_AAAAMMDD.jsonl" {
    use_stubs
    run collect_system_info
    [ "$status" -eq 0 ]
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl"
    [ -f "$arquivo" ]
    jq -e 'has("timestamp")' "$arquivo" >/dev/null
    [ ! -e "${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl" ]
}

@test "collect_system_info em português grava em sistema_AAAAMMDD.jsonl" {
    use_stubs
    SYSMETRICS_LANG=pt
    run collect_system_info
    [ "$status" -eq 0 ]
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl"
    [ -f "$arquivo" ]
    jq -e 'has("data_hora")' "$arquivo" >/dev/null
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl" ]
}

@test "coletas seguidas acrescentam uma linha por coleta ao mesmo arquivo" {
    use_stubs
    collect_system_info
    collect_system_info
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl"
    [ "$(wc -l <"$arquivo")" -eq 2 ]
    [ "$(jq -s 'length' "$arquivo")" -eq 2 ]
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
    [ "$(current_log_file)" = "${SYSMETRICS_LOG_DIR}/system_20991231.jsonl" ]
    date() { echo 21000101; }
    [ "$(current_log_file)" = "${SYSMETRICS_LOG_DIR}/system_21000101.jsonl" ]
    SYSMETRICS_LANG=pt
    [ "$(current_log_file)" = "${SYSMETRICS_LOG_DIR}/sistema_21000101.jsonl" ]
}
