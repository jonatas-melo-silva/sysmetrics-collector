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

### Adicionado

- Opções `--once`, `--loop`, `--version` e `--help`.
- Validação de `SYSMETRICS_INTERVAL` e `SYSMETRICS_MAX_DAYS`, com código de saída 2.
- Unit do systemd e `make install` / `make uninstall`.
- Suíte de testes com bats, lint com shellcheck e shfmt, `make check`.
- Ambiente de desenvolvimento em container (Podman ou Docker).
- CI e workflow de release no GitHub Actions.

### Corrigido

- O arquivo de relatório era fixado no dia em que o processo iniciava; um loop que atravessasse a meia-noite continuava gravando no arquivo do primeiro dia.
- A limpeza de relatórios antigos só rodava ao iniciar; agora roda a cada ciclo.
- O processo demorava até um intervalo inteiro (5 minutos por padrão) para reagir a SIGTERM e SIGINT.
- Falha de um comando de métrica (por exemplo, `free`) passava despercebida; agora fica registrada no relatório.
- Instruções de instalação de dependências e erros iniciais iam só para o `monitor.log`; agora aparecem no terminal.
- Códigos de cor ANSI não são mais escritos em arquivo.
- Erro SC2199 do shellcheck na verificação de dependências.

### Removido

- Arquivo `monitor.log` e os módulos `colors`, `dependencies`, `initializer`, `cleanup` e `src/install/*` (substituídos pelos módulos atuais).
