#!/bin/bash
#===================================================================================
# Dependencies Configuration
# Configuração de dependências do sistema
#===================================================================================

# Previne importação múltipla
if [ -z "$_DEPENDENCIES_SH" ]; then
    readonly _DEPENDENCIES_SH=1
    export _DEPENDENCIES_SH

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

    # Exporta o array associativo de dependências
    export DEPENDENCIES
fi