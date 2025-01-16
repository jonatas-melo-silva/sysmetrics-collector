#!/bin/bash
#===================================================================================
# System Monitor Install - Permissions Setup
# Configuração de permissões dos scripts
#===================================================================================

source "${PROJECT_ROOT}/src/utils/logger.sh"

# Configura as permissões dos scripts
setup_permissions() {
    log_info "Configurando permissões..."
    chmod +x "${PROJECT_ROOT}/system-monitor.sh"
    chmod +x "${PROJECT_ROOT}/install.sh"
}

export -f setup_permissions