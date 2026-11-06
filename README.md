# SysMetrics Collector

[![CI](https://github.com/jonatas-melo-silva/sysmetrics-collector/actions/workflows/ci.yml/badge.svg)](https://github.com/jonatas-melo-silva/sysmetrics-collector/actions/workflows/ci.yml)
[![Licença: MIT](https://img.shields.io/badge/licença-MIT-blue.svg)](LICENSE)

Script Bash que registra a cada 5 minutos o estado de uma máquina Linux (CPU, temperatura, memória, carga, disco e processos mais ativos) em um relatório de texto por dia, e apaga os relatórios com mais de 7 dias. Serve para quem quer um histórico simples do que aconteceu na máquina sem instalar uma stack de monitoramento.

## Instalação

Precisa de Linux com Bash 4 ou mais novo. O script de dependências usa `apt`, então funciona em Debian, Ubuntu, Pop!\_OS e derivados.

```bash
git clone https://github.com/jonatas-melo-silva/sysmetrics-collector.git
cd sysmetrics-collector
sudo scripts/install-deps.sh
```

Para ler a temperatura, o `lm-sensors` precisa conhecer os sensores da sua máquina. Se você ainda não rodou o `sensors-detect`, use a opção abaixo (ela carrega módulos do kernel, por isso não vem ligada por padrão):

```bash
sudo scripts/install-deps.sh --configure-sensors
```

## Uso

Uma coleta e sair:

```bash
bin/sysmetrics-collector --once
```

Coletar continuamente (Ctrl+C encerra na hora):

```bash
bin/sysmetrics-collector
```

### Idioma do relatório

Por padrão os campos saem em inglês. Para português, use `--pt`; `--en` volta ao padrão:

```bash
bin/sysmetrics-collector --pt --once
```

Também dá para fixar o idioma com a variável `SYSMETRICS_LANG` (`en` ou `pt`). Quando as duas coisas aparecem, a opção da linha de comando vale.

### Formato dos relatórios

Os relatórios ficam em `~/system_logs/`, um arquivo por dia, com uma linha JSON (JSONL) por coleta. O idioma muda o nome do arquivo e o nome dos campos:

| Opção | Arquivo | Campos de primeiro nível |
| --- | --- | --- |
| `--en` (padrão) | `system_AAAAMMDD.jsonl` | `timestamp`, `cpu`, `temperatures_c`, `memory`, `system`, `disk`, `processes` |
| `--pt` | `sistema_AAAAMMDD.jsonl` | `data_hora`, `cpu`, `temperaturas_c`, `memoria`, `sistema`, `disco`, `processos` |

Os valores são os mesmos nos dois idiomas. Memória e disco vêm em bytes, a temperatura em °C e a frequência em MHz. Em `processes` (ou `processos`) entram os `SYSMETRICS_TOP_PROCS` comandos com mais uso de CPU, somando os processos de mesmo nome. Cada linha é um JSON completo, então o `jq` lê direto:

```bash
jq '{hora: .timestamp, ram_usada: .memory.ram.used_bytes}' ~/system_logs/system_$(date +%Y%m%d).jsonl
jq '.processes[0]' ~/system_logs/system_$(date +%Y%m%d).jsonl
```

Se o `sensors` não estiver instalado ou falhar (comum em máquina virtual), `temperatures_c` fica `{}` e o resto do registro sai normal. O mesmo vale para qualquer outro comando que falhe: só o campo dele fica vazio. Trocar de idioma no meio do dia grava num segundo arquivo (`system_` e `sistema_` convivem), e a limpeza de relatórios antigos cuida dos dois.

### Como serviço do systemd

```bash
sudo make install
sudo systemctl daemon-reload
sudo systemctl enable --now sysmetrics-collector
```

Nesse modo os relatórios vão para `/var/log/sysmetrics-collector/` e as mensagens do programa para o `journalctl -u sysmetrics-collector`. Para usar o relatório em português, rode `sudo systemctl edit sysmetrics-collector` e acrescente `[Service]` com `Environment=SYSMETRICS_LANG=pt`. Para remover: `sudo make uninstall`.

## Configuração

Tudo se ajusta por variável de ambiente:

| Variável | Padrão | O que faz |
| --- | --- | --- |
| `SYSMETRICS_LOG_DIR` | `$HOME/system_logs` | Diretório dos relatórios |
| `SYSMETRICS_INTERVAL` | `300` | Segundos entre coletas |
| `SYSMETRICS_MAX_DAYS` | `7` | Dias que cada relatório é mantido |
| `SYSMETRICS_TOP_PROCS` | `5` | Quantos grupos de processos entram em cada coleta |
| `SYSMETRICS_LANG` | `en` | Idioma dos campos, `en` ou `pt`. `--en` e `--pt` têm prioridade |

```bash
SYSMETRICS_INTERVAL=60 SYSMETRICS_MAX_DAYS=14 bin/sysmetrics-collector
```

Valores inválidos (inteiros que não sejam positivos, ou idioma diferente de `en` e `pt`) fazem o programa sair com código 2 antes de coletar qualquer coisa.

## Vindo da versão 1.x

Os arquivos mudaram de lugar e as configurações viraram variáveis de ambiente. A lista completa está no [CHANGELOG](CHANGELOG.md).

## Contribuição

Ambiente de desenvolvimento, testes e padrão de commits estão no [CONTRIBUTING.md](CONTRIBUTING.md). Bugs e sugestões vão nas [issues](https://github.com/jonatas-melo-silva/sysmetrics-collector/issues). Para vulnerabilidades, veja o [SECURITY.md](SECURITY.md).

## Licença

[MIT](LICENSE).

## Autor

Jonatas Melo Silva ([@jonatas-melo-silva](https://github.com/jonatas-melo-silva)).
