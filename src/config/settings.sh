#!/bin/bash
#===================================================================================
# System Monitor Settings
# Configurações gerais do sistema de monitoramento
#===================================================================================

# Diretórios e arquivos
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly LOG_DIR="$HOME/system_logs"
readonly LOG_FILE="$LOG_DIR/system_$(date +%Y%m%d).log"
readonly MONITOR_LOG="$LOG_DIR/monitor.log"

# Configurações gerais
readonly MAX_DAYS=7
readonly INTERVAL=300  # 5 minutos
readonly SCRIPT_NAME="system-monitor"
readonly VERSION="1.0.2"

export PROJECT_ROOT LOG_DIR LOG_FILE MONITOR_LOG MAX_DAYS INTERVAL SCRIPT_NAME VERSION