# Contribuindo

## Ambiente de desenvolvimento

Há duas formas de trabalhar. Em ambas, o comando que vale é o mesmo: `make check` (lint + testes), que é o que a CI roda.

### Em container (recomendado)

O `scripts/dev.sh` usa Podman e, se ele não existir, Docker. A imagem traz bats, shellcheck, shfmt e as dependências do programa.

```bash
scripts/dev.sh build          # uma vez
scripts/dev.sh run make check # lint + testes
scripts/dev.sh shell          # shell interativo com o repositório montado
```

Atalhos no Makefile: `make dev-build`, `make dev-check`, `make dev-shell`.

### Na sua máquina

Instale `bats`, `shellcheck` e `shfmt` (em Debian/Ubuntu: `sudo apt install bats shellcheck shfmt`) e rode `make check`.

## Estrutura

```text
bin/sysmetrics-collector     ponto de entrada (opções, loop, sinais)
src/config/settings.sh       configuração e valores padrão
src/core/collector.sh        coleta das métricas e escrita do relatório (JSONL)
src/core/schema.sh           nomes dos campos do registro, em inglês e em português
src/core/retention.sh        remoção de relatórios antigos
src/utils/logger.sh          mensagens do programa (stderr)
src/utils/validators.sh      validação de configuração e dependências
scripts/install-deps.sh      instala dependências com apt
scripts/dev.sh               ambiente de desenvolvimento em container
packaging/systemd/           modelo da unit do systemd
tests/unit, tests/integration  suítes bats
tests/stubs                  comandos falsos (lscpu, sensors, free, top...) com saída fixa
containers/Containerfile     imagem de desenvolvimento
```

## Testes

Os testes usam [bats](https://github.com/bats-core/bats-core). Os comandos de métricas são substituídos por stubs em `tests/stubs`, então a suíte roda igual em qualquer máquina, inclusive em container sem sensores. Para simular a ausência de um comando, use `isolated_path <comando>` do `tests/test_helper.bash`.

```bash
make test                                      # tudo
bats tests/unit/collector.bats                 # um arquivo
bats -r tests --filter "meia-noite"            # por nome
```

Todo bug corrigido deve vir com um teste que falhe sem a correção.

## Estilo

- Scripts passam no `shellcheck` sem avisos e seguem o `shfmt` (4 espaços, definido no `.editorconfig`). `make fmt` formata.
- Cada módulo em `src/` só define funções. Quem faz `source` de todos eles e orquestra é o `bin/sysmetrics-collector`.
- Mensagens do programa saem por `log_info`, `log_warning` e `log_error`.

Se usar [pre-commit](https://pre-commit.com), `pre-commit install` roda o lint antes de cada commit.

## Commits e pull requests

- Commits seguem [Conventional Commits](https://www.conventionalcommits.org/pt-br/): `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `build:`, `ci:`, `chore:`. A descrição vai em português, no imperativo.
- Trabalhe em branch (`feat/...`, `fix/...`) e abra um pull request para a `main`. A CI precisa passar.
- Mudança que afeta quem usa o programa entra no `CHANGELOG.md`.

## Lançando uma versão

1. Atualize `VERSION` e mova as entradas de "Não lançado" para a nova versão no `CHANGELOG.md`.
2. Faça o commit na `main` e crie a tag: `git tag v2.1.0 && git push origin v2.1.0`.
3. O workflow `Release` confere se a tag bate com o `VERSION`, roda lint e testes e publica o release com o tarball.
