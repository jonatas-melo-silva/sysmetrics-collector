#!/bin/bash

#===================================================================================
# System Monitor Script
# Desenvolvido para monitoramento contínuo de métricas do sistema
# Versão: 1.0.0
#===================================================================================

# Configurações
readonly LOG_DIR="$HOME/system_logs"
readonly LOG_FILE="$LOG_DIR/system_$(date +%Y%m%d).log"
readonly MAX_DAYS=7
readonly INTERVAL=300  # 5 minutos
readonly SCRIPT_NAME=$(basename "$0")

# Cores para mensagens de log
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

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

# Verifica dependências
check_dependencies() {
    local deps=("sensors" "free" "df" "uptime")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "Dependência não encontrada: $dep"
            exit 1
        fi
    done
}

# Inicializa diretório de logs
initialize_log_dir() {
    if ! mkdir -p "$LOG_DIR"; then
        log_error "Não foi possível criar diretório de logs: $LOG_DIR"
        exit 1
    fi
}

# Limpa logs antigos
cleanup_old_logs() {
    log_info "Iniciando limpeza de logs antigos..."
    find "$LOG_DIR" -name "system_*.log" -mtime +"$MAX_DAYS" -delete
    log_info "Limpeza de logs concluída"
}

# Coleta informações do sistema
collect_system_info() {
    {
        echo "=================================================================="
        echo "                    Relatório do Sistema"
        echo "                    $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=================================================================="

        echo -e "\n[Informações de CPU]"
        echo "------------------------"
        lscpu | grep "Model name\|CPU MHz"

        echo -e "\n[Temperaturas]"
        echo "------------------------"
        sensors

        echo -e "\n[Uso de Memória]"
        echo "------------------------"
        free -h

        echo -e "\n[Uptime e Carga do Sistema]"
        echo "------------------------"
        uptime

        echo -e "\n[Uso de Disco]"
        echo "------------------------"
        df -h /

        echo -e "\n[Processos Mais Ativos]"
        echo "------------------------"
        ps aux --sort=-%cpu | head -n 6

        echo -e "\n=================================================================="
        echo
    } >> "$LOG_FILE"
}

# Trap para limpeza ao encerrar
cleanup() {
    log_info "Encerrando monitoramento do sistema..."
    exit 0
}

# Função principal
main() {
    trap cleanup SIGINT SIGTERM

    log_info "Iniciando monitoramento do sistema..."
    check_dependencies
    initialize_log_dir
    cleanup_old_logs

    while true; do
        if ! collect_system_info; then
            log_error "Erro ao coletar informações do sistema"
        fi
        sleep "$INTERVAL"
    done
}

# Inicia o script
main "$@" &>> "$LOG_DIR/monitor.log"
