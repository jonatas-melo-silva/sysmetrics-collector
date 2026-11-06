#!/usr/bin/env bash
# Coleta das métricas e escrita do relatório diário. Cada coleta vira uma linha
# JSON (JSONL) acrescentada ao arquivo do dia.
#
# As funções metrics_* devolvem JSON neutro, igual em qualquer idioma. Quem dá
# nome aos campos é core/schema.sh. Quando um comando falha ou não existe, o
# campo correspondente sai null, {} ou [] e a coleta continua.

# O nome do arquivo é calculado a cada coleta. Fixar no início do processo
# faria um loop de vários dias gravar tudo no arquivo do primeiro dia.
# O prefixo acompanha o idioma: system_ (en) ou sistema_ (pt).
current_log_file() {
    local prefix="system"
    if [[ "$SYSMETRICS_LANG" == "pt" ]]; then
        prefix="sistema"
    fi
    printf '%s/%s_%s.jsonl' "$SYSMETRICS_LOG_DIR" "$prefix" "$(date +%Y%m%d)"
}

# Imprime o argumento se for número, senão null.
_num() {
    if [[ "${1:-}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        printf '%s' "$1"
    else
        printf 'null'
    fi
}

# _jq_or <valor de reserva> <argumentos do jq>: lê o stdin e, se o jq falhar
# ou não imprimir nada, imprime o valor de reserva.
_jq_or() {
    local fallback="$1" out
    shift
    out="$(jq "$@" 2>/dev/null)" || out=""
    printf '%s' "${out:-$fallback}"
}

# Limites de frequência em MHz.
metrics_cpu() {
    local raw
    raw="$(lscpu -J 2>/dev/null || true)"
    # shellcheck disable=SC2016  # os $ abaixo são variáveis do jq, não do shell
    _jq_or '{"mhz_max":null,"mhz_min":null}' -c '
        def campo($nome): [.lscpu[] | select(.field | startswith($nome)) | .data | tonumber?] | first;
        { mhz_max: campo("CPU max MHz"), mhz_min: campo("CPU min MHz") }' <<<"$raw"
}

# Frequência atual média de todos os núcleos, em MHz (o sysfs informa em kHz).
metrics_cpu_freq() {
    local freq
    freq="$(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq 2>/dev/null |
        awk '{ s += $1; n++ } END { if (n > 0) printf "%.1f", s / n / 1000; else print "null" }')" || freq=""
    _num "$freq"
}

# Temperaturas em °C: {chip: {sensor: valor}}. Tira o acpitz (leitura travada),
# o campo Adapter e sensores sem temperatura. Sem sensors, sai {}.
metrics_temperatures() {
    local raw
    if ! command -v sensors >/dev/null 2>&1; then
        printf '{}'
        return 0
    fi
    raw="$(sensors -j 2>/dev/null || true)"
    _jq_or '{}' -c '
        del(."acpitz-acpi-0")
        | with_entries(.key |= sub("-(pci|acpi)-.*$"; ""))
        | map_values(
            del(.Adapter)
            | with_entries(select(.value | has("temp1_input")))
            | map_values(.temp1_input)
        )' <<<"$raw"
}

# Memória e swap em bytes.
metrics_memory() {
    local raw
    raw="$(free -b 2>/dev/null || true)"
    # shellcheck disable=SC2016  # os $ abaixo são variáveis do jq, não do shell
    _jq_or '{"ram":{},"swap":{}}' -R -s -c '
        def linha($rotulo):
            split("\n")
            | map(select(startswith($rotulo)) | [splits("\\s+")] | .[1:] | map(tonumber? // null))
            | first // [];
        linha("Mem:") as $m
        | linha("Swap:") as $s
        | {
            ram: { total: $m[0], used: $m[1], free: $m[2], shared: $m[3], buff_cache: $m[4], available: $m[5] },
            swap: { total: $s[0], used: $s[1], free: $s[2] }
        }' <<<"$raw"
}

# Uptime em segundos, usuários logados, threads de CPU e carga média.
metrics_system() {
    local up="" l1="" l5="" l15="" users="" threads=""
    read -r up _ </proc/uptime || true
    read -r l1 l5 l15 _ </proc/loadavg || true
    users="$(who 2>/dev/null | awk 'END { print NR }')" || users=""
    threads="$(nproc 2>/dev/null)" || threads=""
    jq -n -c \
        --argjson up "$(_num "${up%.*}")" \
        --argjson users "$(_num "$users")" \
        --argjson threads "$(_num "$threads")" \
        --argjson m1 "$(_num "$l1")" \
        --argjson m5 "$(_num "$l5")" \
        --argjson m15 "$(_num "$l15")" \
        '{ uptime: $up, users: $users, cpu_threads: $threads, load: { m1: $m1, m5: $m5, m15: $m15 } }'
}

# Disco da raiz, em bytes.
metrics_disk() {
    local raw
    raw="$(df -B1 --output=source,size,used,avail,pcent,target / 2>/dev/null | tail -n +2 || true)"
    _jq_or '[]' -R -s -c '
        split("\n")
        | map(select(length > 0) | [splits("\\s+") | select(length > 0)])
        | map({
            device: .[0],
            total: (.[1] | tonumber),
            used: (.[2] | tonumber),
            available: (.[3] | tonumber),
            used_pct: (.[4] | rtrimstr("%") | tonumber),
            mount: .[5]
        })' <<<"$raw"
}

# Processos agrupados por comando, ordenados pelo %CPU real (top, amostra de
# 3 s). O %CPU do ps é a média desde o início do processo e engana, por isso
# vem do top. Lê só a 2ª amostra do top. cpu_pct e mem_pct são somas do grupo;
# rss_kb soma páginas compartilhadas mais de uma vez, então pode passar do uso
# real de memória do grupo.
metrics_processes() {
    local top_raw ps_raw
    top_raw="$(top -b -n2 -d3 -w 512 2>/dev/null |
        awk '
            /^top -/ { it++ }
            it == 2 && /^ *PID/ { f = 1; next }
            it == 2 && f && NF { print $1, $9 }' || true)"
    ps_raw="$(ps -e -o pid,pmem,rss,cputimes,comm 2>/dev/null | tail -n +2 || true)"
    # shellcheck disable=SC2016  # os $ abaixo são variáveis do jq, não do shell
    _jq_or '[]' -R -s -c --arg top "$top_raw" --argjson n "$SYSMETRICS_TOP_PROCS" '
        def r1: (. * 10 | round) / 10;
        ($top | split("\n") | map(select(length > 0) | split(" "))
            | map({ key: .[0], value: (.[1] | tonumber) }) | from_entries) as $cpu
        | split("\n")
        | map(select(length > 0) | [splits("\\s+") | select(length > 0)])
        | map({
            cpu: ($cpu[.[0]] // 0),
            mem: (.[1] | tonumber),
            rss: (.[2] | tonumber),
            cpu_t: (.[3] | tonumber),
            command: (.[4:] | join(" "))
        })
        | group_by(.command)
        | map({
            command: .[0].command,
            count: length,
            cpu_pct: (map(.cpu) | add | r1),
            mem_pct: (map(.mem) | add | r1),
            rss_kb: (map(.rss) | add),
            cpu_time: (map(.cpu_t) | add)
        })
        | sort_by(-.cpu_pct)
        | .[:$n]' <<<"$ps_raw"
}

# Uma coleta completa, como uma linha JSON no idioma de SYSMETRICS_LANG.
build_record() {
    # Força ponto decimal: em pt_BR o top e o printf gerariam 1,38 e quebrariam o JSON.
    local -x LC_ALL=C
    local cpu freq temp mem sys disk procs
    cpu="$(metrics_cpu)"
    freq="$(metrics_cpu_freq)"
    temp="$(metrics_temperatures)"
    mem="$(metrics_memory)"
    sys="$(metrics_system)"
    disk="$(metrics_disk)"
    procs="$(metrics_processes)"
    jq -n -c \
        --arg lang "$SYSMETRICS_LANG" \
        --arg ts "$(date +%Y-%m-%dT%H:%M:%S%:z)" \
        --argjson cpu "$cpu" \
        --argjson freq "$freq" \
        --argjson temp "$temp" \
        --argjson mem "$mem" \
        --argjson sys "$sys" \
        --argjson disk "$disk" \
        --argjson procs "$procs" \
        "$(record_filter)"
}

collect_system_info() {
    local file record
    if ! mkdir -p "$SYSMETRICS_LOG_DIR"; then
        log_error "Não foi possível criar o diretório de logs: ${SYSMETRICS_LOG_DIR}"
        return 1
    fi
    if ! record="$(build_record)" || [[ -z "$record" ]]; then
        log_error "Falha ao montar o registro da coleta"
        return 1
    fi
    file="$(current_log_file)"
    if ! printf '%s\n' "$record" >>"$file"; then
        log_error "Falha ao escrever em ${file}"
        return 1
    fi
}
