#!/bin/bash
#===================================================================================
# System Monitor Main Script
# Script principal do sistema de monitoramento
#===================================================================================

# Carrega todas as configurações e módulos
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$SCRIPT_DIR"

source "${PROJECT_ROOT}/src/config/settings.sh"
source "${PROJECT_ROOT}/src/config/dependencies.sh"
source "${PROJECT_ROOT}/src/config/colors.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"
source "${PROJECT_ROOT}/src/core/initializer.sh"
source "${PROJECT_ROOT}/src/utils/validators.sh"
source "${PROJECT_ROOT}/src/core/cleanup.sh"
source "${PROJECT_ROOT}/src/core/collector.sh"

# Função principal
main() {
    initialize_log_dir
    trap cleanup SIGINT SIGTERM

    log_info "Iniciando verificação do sistema..."
    check_dependencies

    log_info "Iniciando monitoramento do sistema..."
    cleanup_old_logs

    while true; do
        if ! collect_system_info; then
            log_error "Erro ao coletar informações do sistema"
        fi
        sleep "$INTERVAL"
    done
}

# Inicia o script
# Primeiro garantimos que o diretório existe
initialize_log_dir

# Então iniciamos o logging
main "$@" &>> "$MONITOR_LOG"