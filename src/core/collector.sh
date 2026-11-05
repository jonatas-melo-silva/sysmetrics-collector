#!/usr/bin/env bash
# Coleta das métricas e escrita do relatório diário.

# O nome do arquivo é calculado a cada coleta. Fixar no início do processo
# faria um loop de vários dias gravar tudo no arquivo do primeiro dia.
current_log_file() {
    printf '%s/system_%s.log' "$SYSMETRICS_LOG_DIR" "$(date +%Y%m%d)"
}

_section() {
    printf '\n[%s]\n------------------------\n' "$1"
}

# Roda um comando e, se ele falhar, registra isso no relatório em vez de abortar.
_run() {
    "$@" 2>&1 || printf 'indisponível (falha ao executar: %s)\n' "$1"
}

report_header() {
    printf '==================================================================\n'
    printf '                    Relatório do Sistema\n'
    printf '                    %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf '==================================================================\n'
}

report_cpu() {
    _section "Informações de CPU"
    _run lscpu | grep -E 'Model name|CPU MHz' || echo "indisponível"
}

report_temperature() {
    _section "Temperaturas"
    if command -v sensors >/dev/null 2>&1; then
        _run sensors
    else
        echo "indisponível (sensors não instalado)"
    fi
}

report_memory() {
    _section "Uso de Memória"
    _run free -h
}

report_uptime() {
    _section "Uptime e Carga do Sistema"
    _run uptime
}

report_disk() {
    _section "Uso de Disco"
    _run df -h /
}

report_processes() {
    _section "Processos Mais Ativos"
    # sed lê tudo; head fecharia o pipe antes e o ps morreria com SIGPIPE.
    _run ps aux --sort=-%cpu | sed -n '1,6p'
}

build_report() {
    report_header
    report_cpu
    report_temperature
    report_memory
    report_uptime
    report_disk
    report_processes
    printf '\n==================================================================\n\n'
}

collect_system_info() {
    local file report
    if ! mkdir -p "$SYSMETRICS_LOG_DIR"; then
        log_error "Não foi possível criar o diretório de logs: ${SYSMETRICS_LOG_DIR}"
        return 1
    fi
    report="$(build_report)"
    file="$(current_log_file)"
    if ! printf '%s\n' "$report" >>"$file"; then
        log_error "Falha ao escrever em ${file}"
        return 1
    fi
}
