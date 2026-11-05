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
    arquivo="${SYSMETRICS_LOG_DIR}/system_$(date +%Y%m%d).log"
    [ -f "$arquivo" ]
    grep -q "\[Uso de Disco\]" "$arquivo"
}

@test "--once apaga relatórios vencidos" {
    use_stubs
    mkdir -p "$SYSMETRICS_LOG_DIR"
    touch -d "10 days ago" "${SYSMETRICS_LOG_DIR}/system_19990101.log"
    run "$BIN" --once
    [ ! -e "${SYSMETRICS_LOG_DIR}/system_19990101.log" ]
}

@test "modo loop encerra logo ao receber SIGTERM, sem esperar o intervalo" {
    use_stubs
    SYSMETRICS_INTERVAL=300 "$BIN" 3>&- &
    local pid=$!
    for _ in $(seq 50); do
        compgen -G "${SYSMETRICS_LOG_DIR}/system_*.log" >/dev/null && break
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
