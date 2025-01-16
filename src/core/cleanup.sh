#!/bin/bash
#===================================================================================
# System Monitor Cleanup
# Funções de limpeza de logs antigos
#===================================================================================

source "${PROJECT_ROOT}/src/config/settings.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"


# Limpa logs antigos
cleanup_old_logs() {
    log_info "Iniciando limpeza de logs antigos..."
    find "$LOG_DIR" -name "system_*.log" -mtime +"$MAX_DAYS" -delete
    log_info "Limpeza de logs concluída"
}

# Trap para limpeza ao encerrar
cleanup() {
    log_info "Encerrando monitoramento do sistema..."
    exit 0
}

export -f cleanup_old_logs cleanup