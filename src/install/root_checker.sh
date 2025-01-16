#!/bin/bash
#===================================================================================
# System Monitor Install - Root Checker
# Verificação de privilégios de root
#===================================================================================

source "${PROJECT_ROOT}/src/utils/logger.sh"

# Verifica se está rodando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Por favor, execute o script como root (sudo)"
        exit 1
    fi
}

export -f check_root