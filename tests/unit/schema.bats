#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_env
    load_modules core/schema
}
teardown() { teardown_env; }

# O filtro começa com "def names: {...};". Cortando antes de "names[$lang]",
# sobra só a tabela de nomes para inspecionar.
nomes() {
    local tabela
    tabela="$(record_filter | sed '/^names\[\$lang\] as/,$d')"
    jq -n -c "${tabela} names | $1"
}

@test "inglês e português definem os mesmos campos" {
    [ "$(nomes '(.en | keys) == (.pt | keys)')" = "true" ]
}

@test "os nomes dos campos em inglês e em português são os dos scripts originais" {
    [ "$(nomes '.en.timestamp')" = '"timestamp"' ]
    [ "$(nomes '.pt.timestamp')" = '"data_hora"' ]
    [ "$(nomes '.en.processes')" = '"processes"' ]
    [ "$(nomes '.pt.processes')" = '"processos"' ]
}

@test "dentro de cada idioma, campos irmãos não repetem nome" {
    # Se dois campos do mesmo objeto tivessem o mesmo nome, um sobrescreveria o outro.
    [ "$(nomes '[.en.total, .en.used, .en.free, .en.shared, .en.buff_cache, .en.available] | unique | length')" = "6" ]
    [ "$(nomes '[.pt.total, .pt.used, .pt.free, .pt.shared, .pt.buff_cache, .pt.available] | unique | length')" = "6" ]
    [ "$(nomes '[.en.command, .en.count, .en.cpu_pct, .en.mem_pct, .en.rss_kb, .en.cpu_time] | unique | length')" = "6" ]
    [ "$(nomes '[.pt.command, .pt.count, .pt.cpu_pct, .pt.mem_pct, .pt.rss_kb, .pt.cpu_time] | unique | length')" = "6" ]
}
