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

Os relatórios ficam em `~/system_logs/system_AAAAMMDD.log`, um arquivo por dia. Cada coleta acrescenta um bloco com estas seções:

```text
$ grep '^\[' ~/system_logs/system_$(date +%Y%m%d).log
[Informações de CPU]
[Temperaturas]
[Uso de Memória]
[Uptime e Carga do Sistema]
[Uso de Disco]
[Processos Mais Ativos]
```

Se o `sensors` não estiver instalado ou falhar (comum em máquina virtual), a seção de temperatura registra "indisponível" e o resto do relatório sai normal.

### Como serviço do systemd

```bash
sudo make install
sudo systemctl daemon-reload
sudo systemctl enable --now sysmetrics-collector
```

Nesse modo os relatórios vão para `/var/log/sysmetrics-collector/` e as mensagens do programa para o `journalctl -u sysmetrics-collector`. Para remover: `sudo make uninstall`.

## Configuração

Tudo se ajusta por variável de ambiente:

| Variável | Padrão | O que faz |
| --- | --- | --- |
| `SYSMETRICS_LOG_DIR` | `$HOME/system_logs` | Diretório dos relatórios |
| `SYSMETRICS_INTERVAL` | `300` | Segundos entre coletas |
| `SYSMETRICS_MAX_DAYS` | `7` | Dias que cada relatório é mantido |

```bash
SYSMETRICS_INTERVAL=60 SYSMETRICS_MAX_DAYS=14 bin/sysmetrics-collector
```

Valores que não sejam inteiros positivos fazem o programa sair com código 2 antes de coletar qualquer coisa.

## Vindo da versão 1.x

Os arquivos mudaram de lugar e as configurações viraram variáveis de ambiente. A lista completa está no [CHANGELOG](CHANGELOG.md).

## Contribuição

Ambiente de desenvolvimento, testes e padrão de commits estão no [CONTRIBUTING.md](CONTRIBUTING.md). Bugs e sugestões vão nas [issues](https://github.com/jonatas-melo-silva/sysmetrics-collector/issues). Para vulnerabilidades, veja o [SECURITY.md](SECURITY.md).

## Licença

[MIT](LICENSE).

## Autor

Jonatas Melo Silva ([@jonatas-melo-silva](https://github.com/jonatas-melo-silva)).
