#!/usr/bin/env bats

load ../test_helper

setup() { setup_env; }
teardown() { teardown_env; }

@test "usa os valores padrão quando nada é definido" {
    unset SYSMETRICS_LOG_DIR
    load_modules config/settings
    [ "$SYSMETRICS_INTERVAL" = "300" ]
    [ "$SYSMETRICS_MAX_DAYS" = "7" ]
    [ "$SYSMETRICS_TOP_PROCS" = "5" ]
    [ "$SYSMETRICS_LOG_DIR" = "${HOME}/system_logs" ]
}

@test "o idioma padrão é en" {
    load_modules config/settings
    [ "$SYSMETRICS_LANG" = "en" ]
}

@test "SYSMETRICS_LANG sobrescreve o idioma padrão" {
    export SYSMETRICS_LANG=pt
    load_modules config/settings
    [ "$SYSMETRICS_LANG" = "pt" ]
}

@test "variáveis de ambiente sobrescrevem os padrões" {
    export SYSMETRICS_INTERVAL=60 SYSMETRICS_MAX_DAYS=3 SYSMETRICS_LOG_DIR=/tmp/outro
    load_modules config/settings
    [ "$SYSMETRICS_INTERVAL" = "60" ]
    [ "$SYSMETRICS_MAX_DAYS" = "3" ]
    [ "$SYSMETRICS_LOG_DIR" = "/tmp/outro" ]
}

@test "a versão vem do arquivo VERSION" {
    load_modules config/settings
    [ "$SYSMETRICS_VERSION" = "$(tr -d '[:space:]' <"${PROJECT_DIR}/VERSION")" ]
}
