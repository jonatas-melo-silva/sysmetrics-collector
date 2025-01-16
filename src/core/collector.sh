#!/bin/bash
#===================================================================================
# System Data Collector
# Funções de coleta de dados do sistema
#===================================================================================

source "${PROJECT_ROOT}/src/config/settings.sh"

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

export -f collect_system_info