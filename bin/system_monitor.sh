#!/bin/bash

#===================================================================================
# System Monitor Script
# Desenvolvido para monitoramento contínuo de métricas do sistema
# Versão: 1.0.2
#===================================================================================

# Configurações
readonly LOG_DIR="$HOME/system_logs"
readonly LOG_FILE="$LOG_DIR/system_$(date +%Y%m%d).log"
readonly MONITOR_LOG="$LOG_DIR/monitor.log"
readonly MAX_DAYS=7
readonly INTERVAL=300  # 5 minutos
readonly SCRIPT_NAME=$(basename "$0")

# Cores para mensagens de log
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Lista de dependências e seus pacotes
declare -A DEPENDENCIES=(
    ["sensors"]="lm-sensors"    # Para monitoramento de temperatura
    ["free"]="procps"          # Para informações de memória
    ["ps"]="procps"            # Para informações de processos
    ["uptime"]="procps"        # Para tempo de atividade do sistema
    ["df"]="coreutils"         # Para informações de disco
    ["lscpu"]="util-linux"     # Para informações da CPU
    ["grep"]="grep"            # Para filtrar saídas
    ["head"]="coreutils"       # Para limitar saídas
    ["find"]="findutils"       # Para limpeza de logs antigos
)

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

# Inicializa diretório de logs
initialize_log_dir() {
    if ! mkdir -p "$LOG_DIR"; then
        echo -e "${RED}[ERROR]${NC} Não foi possível criar diretório de logs: $LOG_DIR"
        exit 1
    fi
    # Toca os arquivos de log para garantir que existem
    touch "$LOG_FILE"
    touch "$MONITOR_LOG"
}

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
    # Primeiro criamos o diretório e arquivos de log
    initialize_log_dir

    # Agora podemos começar a logar
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
