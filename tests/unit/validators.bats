#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules config/settings utils/logger utils/validators
}
teardown() { teardown_env; }

@test "validate_settings aceita os valores padrão" {
    run validate_settings
    [ "$status" -eq 0 ]
}

@test "validate_settings rejeita intervalo inválido" {
    for valor in abc 0 -5 1.5 ""; do
        SYSMETRICS_INTERVAL="$valor"
        run validate_settings
        [ "$status" -eq 1 ]
        [[ "$output" == *"SYSMETRICS_INTERVAL"* ]]
    done
}

@test "validate_settings rejeita retenção inválida" {
    SYSMETRICS_MAX_DAYS=0
    run validate_settings
    [ "$status" -eq 1 ]
    [[ "$output" == *"SYSMETRICS_MAX_DAYS"* ]]
}

@test "validate_settings rejeita número de processos inválido" {
    SYSMETRICS_TOP_PROCS=0
    run validate_settings
    [ "$status" -eq 1 ]
    [[ "$output" == *"SYSMETRICS_TOP_PROCS"* ]]
}

@test "validate_settings aceita os idiomas en e pt" {
    for valor in en pt; do
        SYSMETRICS_LANG="$valor"
        run validate_settings
        [ "$status" -eq 0 ]
    done
}

@test "validate_settings rejeita idioma desconhecido" {
    for valor in fr EN pt-BR ""; do
        SYSMETRICS_LANG="$valor"
        run validate_settings
        [ "$status" -eq 1 ]
        [[ "$output" == *"SYSMETRICS_LANG"* ]]
    done
}

@test "check_dependencies passa quando tudo existe" {
    use_stubs
    run check_dependencies
    [ "$status" -eq 0 ]
}

@test "check_dependencies falha e indica o pacote do comando ausente" {
    isolated_path free
    run check_dependencies
    [ "$status" -eq 1 ]
    [[ "$output" == *"Dependências ausentes: free"* ]]
    [[ "$output" == *"apt install -y procps"* ]]
}

@test "check_dependencies não repete pacote quando faltam vários comandos dele" {
    isolated_path free ps top
    run check_dependencies
    [ "$status" -eq 1 ]
    [[ "$output" == *"apt install -y procps"* ]]
    [[ "$output" != *"procps procps"* ]]
}

@test "ausência do sensors é só um aviso" {
    isolated_path sensors
    run check_dependencies
    [ "$status" -eq 0 ]
    [[ "$output" == *"lm-sensors"* ]]
}

@test "install-deps.sh instala todos os pacotes que o programa exige" {
    local pkg
    [ "${#SYSMETRICS_REQUIRED[@]}" -gt 0 ]
    for pkg in "${SYSMETRICS_REQUIRED[@]}"; do
        grep -qw -- "$pkg" "${PROJECT_DIR}/scripts/install-deps.sh"
    done
}
