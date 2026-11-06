#!/usr/bin/env bash
# Configuração central. Todo valor pode ser sobrescrito por variável de ambiente.
# shellcheck disable=SC2034

[[ -z "${_SYSMETRICS_SETTINGS:-}" ]] || return 0
_SYSMETRICS_SETTINGS=1

: "${SYSMETRICS_ROOT:?SYSMETRICS_ROOT precisa estar definido}"

SYSMETRICS_VERSION="$(tr -d '[:space:]' <"${SYSMETRICS_ROOT}/VERSION" 2>/dev/null || true)"
SYSMETRICS_VERSION="${SYSMETRICS_VERSION:-desconhecida}"

: "${SYSMETRICS_LOG_DIR:=${HOME}/system_logs}"
: "${SYSMETRICS_MAX_DAYS:=7}"
: "${SYSMETRICS_INTERVAL:=300}"
: "${SYSMETRICS_LANG:=en}"
: "${SYSMETRICS_TOP_PROCS:=5}"
