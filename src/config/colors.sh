#!/bin/bash
#===================================================================================
# Colors Configuration
# Configuração de cores para o sistema de logging
#===================================================================================

# Previne importação múltipla
if [ -z "$_COLORS_SH" ]; then
    readonly _COLORS_SH=1
    export _COLORS_SH

    # Cores para mensagens de log
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color

    # Exporta as cores para subshells
    export RED
    export GREEN
    export YELLOW
    export BLUE
    export NC
fi