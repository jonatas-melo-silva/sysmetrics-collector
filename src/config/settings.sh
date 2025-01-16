#!/bin/bash
#===================================================================================
# System Monitor Settings
# Configurações gerais do sistema de monitoramento
#===================================================================================

# Previne importação múltipla
if [ -z "$_SETTINGS_SH" ]; then
    readonly _SETTINGS_SH=1
    export _SETTINGS_SH

    # Se PROJECT_ROOT não estiver definido, define
    if [ -z "$PROJECT_ROOT" ]; then
        readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        export PROJECT_ROOT
    fi

    # Configurações de diretórios e arquivos
    readonly LOG_DIR="$HOME/system_logs"
    readonly LOG_FILE="$LOG_DIR/system_$(date +%Y%m%d).log"
    readonly MONITOR_LOG="$LOG_DIR/monitor.log"

    # Configurações gerais
    readonly MAX_DAYS=7
    readonly INTERVAL=300  # 5 minutos
    readonly SCRIPT_NAME=$(basename "$0")
    readonly VERSION="1.0.2"

    # Exporta as configurações
    export LOG_DIR
    export LOG_FILE
    export MONITOR_LOG
    export MAX_DAYS
    export INTERVAL
    export SCRIPT_NAME
    export VERSION
fi