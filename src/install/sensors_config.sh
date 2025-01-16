#!/bin/bash
#===================================================================================
# System Monitor Install - Sensors Configuration
# Configuração dos sensores do sistema
#===================================================================================

source "${PROJECT_ROOT}/src/utils/logger.sh"

# Configura os sensores do sistema
configure_sensors() {
    if command -v sensors-detect &> /dev/null; then
        log_info "Configurando sensores..."
        if ! sensors-detect --auto; then
            log_warning "Falha ao configurar sensores automaticamente"
        fi
        systemctl restart kmod
    fi
}

export -f configure_sensors