#!/bin/bash
#===================================================================================
# System Monitor Install Script
# Script de instalação do sistema de monitoramento
#===================================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$SCRIPT_DIR"

source "${PROJECT_ROOT}/src/config/dependencies.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"

# Verifica se está rodando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Por favor, execute o script como root (sudo)"
        exit 1
    fi
}

# Instala as dependências necessárias
install_dependencies() {
    log_info "Atualizando lista de pacotes..."
    if ! apt update; then
        log_error "Falha ao atualizar lista de pacotes"
        exit 1
    fi

    log_info "Instalando dependências necessárias..."
    local packages=()
    for package in "${DEPENDENCIES[@]}"; do
        packages+=("$package")
    done

    if ! apt install -y "${packages[@]}"; then
        log_error "Falha ao instalar dependências"
        exit 1
    fi
}

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

# Configura as permissões dos scripts
setup_permissions() {
    log_info "Configurando permissões..."
    chmod +x "${PROJECT_ROOT}/system-monitor.sh"
    chmod +x "${PROJECT_ROOT}/install.sh"
}

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

export -f check_root
export -f install_dependencies
export -f configure_sensors
export -f setup_permissions