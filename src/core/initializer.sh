#!/bin/bash
#===================================================================================
# System Monitor Initializer
# Funções de inicialização do sistema de monitoramento
#===================================================================================

source "${PROJECT_ROOT}/src/config/settings.sh"
source "${PROJECT_ROOT}/src/config/colors.sh"


# Inicializa diretório de logs
initialize_log_dir() {
    if ! mkdir -p "$LOG_DIR"; then
        echo -e "${RED}[ERROR]${NC} Não foi possível criar diretório de logs: $LOG_DIR"
        exit 1
    fi
    # Toca os arquivos de log para garantir que existem
    touch "$LOG_FILE"
    touch "$MONITOR_LOG"
}

export -f initialize_log_dir