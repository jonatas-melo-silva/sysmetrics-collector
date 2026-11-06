#!/usr/bin/env bats

load ../test_helper

setup() { setup_env; }
teardown() { teardown_env; }

@test "--version mostra a versão do arquivo VERSION" {
    run "$BIN" --version
    [ "$status" -eq 0 ]
    [ "$output" = "sysmetrics-collector $(tr -d '[:space:]' <"${PROJECT_DIR}/VERSION")" ]
}

@test "--help mostra o uso" {
    run "$BIN" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uso: sysmetrics-collector"* ]]
    [[ "$output" == *"--en"* ]]
    [[ "$output" == *"--pt"* ]]
}

@test "opção desconhecida sai com 2" {
    run "$BIN" --nada
    [ "$status" -eq 2 ]
    [[ "$output" == *"Opção desconhecida: --nada"* ]]
}

@test "configuração inválida sai com 2 sem coletar nada" {
    use_stubs
    SYSMETRICS_INTERVAL=abc run "$BIN" --once
    [ "$status" -eq 2 ]
    [ ! -d "$SYSMETRICS_LOG_DIR" ]
}

@test "dependência obrigatória ausente sai com 1" {
    isolated_path free
    run "$BIN" --once
    [ "$status" -eq 1 ]
    [[ "$output" == *"Dependências ausentes: free"* ]]
}

@test "--once faz uma coleta, grava o relatório e termina" {
    use_stubs
    run "$BIN" --once
    [ "$status" -eq 0 ]
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl"
    [ -f "$arquivo" ]
    [ "$(wc -l <"$arquivo")" -eq 1 ]
    jq -e '.disk[0].mount == "/"' "$arquivo" >/dev/null
}

@test "sem flag nem variável o relatório sai em inglês" {
    use_stubs
    run "$BIN" --once
    [ "$status" -eq 0 ]
    jq -e 'has("timestamp") and has("memory")' "${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl" >/dev/null
    [ ! -e "${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl" ]
}

@test "--en escolhe o relatório em inglês" {
    use_stubs
    run "$BIN" --en --once
    [ "$status" -eq 0 ]
    jq -e 'has("timestamp") and has("memory")' "${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl" >/dev/null
}

@test "--pt escolhe o relatório em português" {
    use_stubs
    run "$BIN" --pt --once
    [ "$status" -eq 0 ]
    local arquivo
    arquivo="${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl"
    [ -f "$arquivo" ]
    jq -e 'has("data_hora") and has("memoria") and .memoria.ram.usada_bytes == 4000000000' "$arquivo" >/dev/null
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl" ]
}

@test "a ordem das opções não importa" {
    use_stubs
    run "$BIN" --once --pt
    [ "$status" -eq 0 ]
    [ -f "${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl" ]
}

@test "SYSMETRICS_LANG=pt escolhe o português sem flag" {
    use_stubs
    SYSMETRICS_LANG=pt run "$BIN" --once
    [ "$status" -eq 0 ]
    [ -f "${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl" ]
}

@test "a flag tem prioridade sobre SYSMETRICS_LANG" {
    use_stubs
    SYSMETRICS_LANG=pt run "$BIN" --en --once
    [ "$status" -eq 0 ]
    [ -f "${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).jsonl" ]
    [ ! -e "${SYSMETRICS_LOG_DIR}/sistema_$(date +%Y%m%d).jsonl" ]
}

@test "SYSMETRICS_LANG inválido sai com 2 sem coletar nada" {
    use_stubs
    SYSMETRICS_LANG=fr run "$BIN" --once
    [ "$status" -eq 2 ]
    [[ "$output" == *"SYSMETRICS_LANG"* ]]
    [ ! -d "$SYSMETRICS_LOG_DIR" ]
}

@test "--once apaga relatórios vencidos" {
    use_stubs
    mkdir -p "$SYSMETRICS_LOG_DIR"
    touch -d "10 days ago" "${SYSMETRICS_LOG_DIR}/system_19990101.jsonl" "${SYSMETRICS_LOG_DIR}/sistema_19990101.jsonl"
    run "$BIN" --once
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_19990101.jsonl" ]
    [ ! -e "${SYSMETRICS_LOG_DIR}/sistema_19990101.jsonl" ]
}

@test "modo loop encerra logo ao receber SIGTERM, sem esperar o intervalo" {
    use_stubs
    SYSMETRICS_INTERVAL=300 "$BIN" 3>&- &
    local pid=$!
    for _ in $(seq 50); do
        compgen -G "${SYSMETRICS_LOG_DIR}/system_*.jsonl" >/dev/null && break
        sleep 0.1
    done
    kill -TERM "$pid"
    for _ in $(seq 30); do
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.1
    done
    if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid"
        echo "o processo continuou vivo 3s depois do SIGTERM" >&2
        return 1
    fi
    local rc=0
    wait "$pid" || rc=$?
    [ "$rc" -eq 0 ]
}
