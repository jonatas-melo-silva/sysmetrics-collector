#!/bin/bash
#===================================================================================
# System Monitor Install - Package Installer
# Instalação de dependências do sistema
#===================================================================================

source "${PROJECT_ROOT}/src/config/dependencies.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"

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

export -f install_dependencies