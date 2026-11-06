#!/usr/bin/env bash
# Validação de configuração e de dependências.

# comando obrigatório -> pacote Debian/Ubuntu que o fornece
declare -gA SYSMETRICS_REQUIRED=(
    [lscpu]=util-linux
    [free]=procps
    [ps]=procps
    [top]=procps
    [df]=coreutils
    [date]=coreutils
    [sort]=coreutils
    [tail]=coreutils
    [cat]=coreutils
    [nproc]=coreutils
    [who]=coreutils
    [find]=findutils
    [awk]=gawk
    [jq]=jq
)

validate_settings() {
    local name value rc=0
    for name in SYSMETRICS_INTERVAL SYSMETRICS_MAX_DAYS SYSMETRICS_TOP_PROCS; do
        value="${!name}"
        if ! [[ "$value" =~ ^[1-9][0-9]*$ ]]; then
            log_error "${name} deve ser um inteiro positivo (valor atual: '${value}')"
            rc=1
        fi
    done
    if [[ "$SYSMETRICS_LANG" != "en" && "$SYSMETRICS_LANG" != "pt" ]]; then
        log_error "SYSMETRICS_LANG deve ser 'en' ou 'pt' (valor atual: '${SYSMETRICS_LANG}')"
        rc=1
    fi
    return "$rc"
}

# Retorna 1 se faltar algum comando obrigatório. A ausência do sensors
# (lm-sensors) só gera aviso: máquinas virtuais e containers não têm sensores.
check_dependencies() {
    local cmd pkg
    local -a cmds=() missing_cmds=() missing_pkgs=()

    mapfile -t cmds < <(printf '%s\n' "${!SYSMETRICS_REQUIRED[@]}" | sort)
    for cmd in "${cmds[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 && continue
        missing_cmds+=("$cmd")
        pkg="${SYSMETRICS_REQUIRED[$cmd]}"
        [[ " ${missing_pkgs[*]:-} " == *" ${pkg} "* ]] || missing_pkgs+=("$pkg")
    done

    if ((${#missing_cmds[@]} > 0)); then
        log_error "Dependências ausentes: ${missing_cmds[*]}"
        log_error "Instale com: sudo apt install -y ${missing_pkgs[*]}"
        return 1
    fi

    if ! command -v sensors >/dev/null 2>&1; then
        log_warning "sensors (pacote lm-sensors) não encontrado: a seção de temperatura ficará indisponível"
    fi
}
