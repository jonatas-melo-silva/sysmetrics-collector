#!/bin/bash
#===================================================================================
# Logger Utilities
# Funções de logging do sistema
#===================================================================================

source "${PROJECT_ROOT}/src/config/colors.sh"

# Função para logging de erros
log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Função para logging de informações
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Função para logging de avisos
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

export -f log_error log_info log_warning