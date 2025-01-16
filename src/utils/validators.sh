#!/bin/bash
#===================================================================================
# System Monitor Validators
# Funções de validação de dependências
#===================================================================================

source "${PROJECT_ROOT}/src/config/dependencies.sh"
source "${PROJECT_ROOT}/src/utils/logger.sh"

# Verifica dependências
check_dependencies() {
    local missing_deps=()
    local missing_packages=()

    log_info "Verificando dependências..."

    for cmd in "${!DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
            if [[ ! " ${missing_packages[@]} " =~ " ${DEPENDENCIES[$cmd]} " ]]; then
                missing_packages+=("${DEPENDENCIES[$cmd]}")
            fi
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Dependências faltando: ${missing_deps[*]}"
        echo -e "\nPara instalar todas as dependências necessárias, execute:"
        echo -e "sudo apt update && sudo apt install -y ${missing_packages[*]}"

        if [[ " ${missing_packages[@]} " =~ "lm-sensors" ]]; then
            echo -e "\nApós instalar lm-sensors, execute:"
            echo "sudo sensors-detect --auto"
            echo "sudo systemctl restart kmod"
        fi

        exit 1
    fi

    log_info "Todas as dependências estão instaladas."
}

export -f check_dependencies