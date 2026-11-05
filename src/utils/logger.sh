#!/usr/bin/env bash
# Mensagens de log do próprio programa. Vão para stderr (terminal ou journald),
# com cor só quando stderr é um terminal e NO_COLOR não está definido.

_log() {
    local level="$1" color="$2" ts
    shift 2
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        printf '%b[%s]%b %s - %s\n' "$color" "$level" '\033[0m' "$ts" "$*" >&2
    else
        printf '[%s] %s - %s\n' "$level" "$ts" "$*" >&2
    fi
}

log_info() { _log INFO '\033[0;32m' "$@"; }
log_warning() { _log WARNING '\033[1;33m' "$@"; }
log_error() { _log ERROR '\033[0;31m' "$@"; }
