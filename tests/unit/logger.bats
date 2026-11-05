#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules utils/logger
}
teardown() { teardown_env; }

@test "log_info escreve nível, data e mensagem" {
    run log_info "tudo certo"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^\[INFO\]\ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9:]{8}\ -\ tudo\ certo$ ]]
}

@test "log_warning e log_error usam o nível correto" {
    run log_warning "atenção"
    [[ "$output" == "[WARNING] "*"atenção" ]]
    run log_error "falhou"
    [[ "$output" == "[ERROR] "*"falhou" ]]
}

@test "mensagens de log não vão para stdout" {
    run bash -c 'source "$1/src/utils/logger.sh"; log_info oi 2>/dev/null' _ "$PROJECT_DIR"
    [ -z "$output" ]
}
