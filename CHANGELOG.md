# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

Versão 2.0.0, ainda sem tag.

### Alterado (quebra compatibilidade com a 1.x)

- O ponto de entrada passou de `sysmetrics-collector.sh` para `bin/sysmetrics-collector`.
- As configurações viraram variáveis de ambiente com prefixo: `LOG_DIR` é `SYSMETRICS_LOG_DIR`, `INTERVAL` é `SYSMETRICS_INTERVAL` e `MAX_DAYS` é `SYSMETRICS_MAX_DAYS`. Os padrões continuam os mesmos.
- As mensagens do programa saem em stderr (terminal ou journald) e não mais no `monitor.log`.
- A retenção usa minutos (`-mmin`) em vez de dias inteiros: um relatório é apagado ao passar de `SYSMETRICS_MAX_DAYS` dias, e não de `SYSMETRICS_MAX_DAYS` dias mais a parte fracionária.
- `install_dependencies.sh` virou `scripts/install-deps.sh`. O `sensors-detect --auto` e o `systemctl restart kmod` deixaram de rodar por padrão; use `--configure-sensors`.
- Ausência do `sensors` agora é aviso, não erro.
- O relatório diário deixou de ser texto com seções (`[Uso de Memória]` e similares) e virou JSONL: uma linha JSON por coleta em `system_AAAAMMDD.jsonl` (ou `sistema_AAAAMMDD.jsonl` com `--pt`). Os campos, as unidades e o agrupamento de processos seguem os scripts `sysmetrics_en.sh` e `sysmetrics_pt.sh`.
- Dependências: o coletor passa a exigir `jq`, `top`, `awk`, `nproc` e `who`, e deixa de exigir `uptime`, `sed` e `grep`. O `install-deps.sh` instala `jq` e `gawk`.

### Adicionado

- Opções `--once`, `--loop`, `--version` e `--help`.
- Opções `--en` (padrão) e `--pt` para escolher o idioma do relatório, e a variável `SYSMETRICS_LANG` com o mesmo efeito. A opção da linha de comando tem prioridade.
- Variável `SYSMETRICS_TOP_PROCS` (padrão 5) para o número de grupos de processos por coleta.
- Validação de `SYSMETRICS_INTERVAL`, `SYSMETRICS_MAX_DAYS`, `SYSMETRICS_TOP_PROCS` e `SYSMETRICS_LANG`, com código de saída 2.
- Unit do systemd e `make install` / `make uninstall`.
- Suíte de testes com bats, lint com shellcheck e shfmt, `make check`.
- Ambiente de desenvolvimento em container (Podman ou Docker).
- CI e workflow de release no GitHub Actions.

### Corrigido

- O arquivo de relatório era fixado no dia em que o processo iniciava; um loop que atravessasse a meia-noite continuava gravando no arquivo do primeiro dia.
- A limpeza de relatórios antigos só rodava ao iniciar; agora roda a cada ciclo.
- O processo demorava até um intervalo inteiro (5 minutos por padrão) para reagir a SIGTERM e SIGINT.
- Falha de um comando de métrica (por exemplo, `free`) passava despercebida; agora só o campo dele sai vazio (`null`, `{}` ou `[]`) e a coleta continua.
- Instruções de instalação de dependências e erros iniciais iam só para o `monitor.log`; agora aparecem no terminal.
- Códigos de cor ANSI não são mais escritos em arquivo.
- Erro SC2199 do shellcheck na verificação de dependências.

### Removido

- Arquivo `monitor.log` e os módulos `colors`, `dependencies`, `initializer`, `cleanup` e `src/install/*` (substituídos pelos módulos atuais).
