#!/bin/bash
#===================================================================================
# System Monitor Install Script
# Script de instalação do sistema de monitoramento
#===================================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$SCRIPT_DIR"

# Carrega os módulos de instalação
source "${PROJECT_ROOT}/src/config/dependencies.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"
source "${PROJECT_ROOT}/src/install/root_checker.sh"
source "${PROJECT_ROOT}/src/install/package_installer.sh"
source "${PROJECT_ROOT}/src/install/sensors_config.sh"
source "${PROJECT_ROOT}/src/install/permissions_setup.sh"

# Função principal
main() {
    log_info "Iniciando instalação do System Monitor..."

    check_root
    install_dependencies
    configure_sensors
    setup_permissions

    log_info "Instalação concluída com sucesso!"
    log_info "Para iniciar o monitoramento, execute: ./system-monitor.sh"
}

# Inicia a instalação
main "$@"