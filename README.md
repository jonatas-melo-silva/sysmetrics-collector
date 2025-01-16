# System Monitor Script

Um script Bash para monitoramento contínuo de métricas do sistema, incluindo:

- Informações de CPU
- Temperatura
- Uso de memória e disco
- Processos ativos

## Estrutura do Projeto

```plaintext
system-monitor/
├── README.md
├── LICENSE
├── install.sh
├── system-monitor.sh
└── src/
    ├── config/
    │   ├── colors.sh
    │   ├── dependencies.sh
    │   └── settings.sh
    ├── utils/
    │   ├── logger.sh
    │   └── validators.sh
    └── core/
        ├── collector.sh
        ├── initializer.sh
        └── cleanup.sh
├── docs/
│   └── documentation.md (opcional, para documentação detalhada)
├── tests/
│   └── test_system_monitor.sh (opcional, para testes)
├── .gitignore
```

## Como usar

1. Clone o repositorio:

    ```bash
    git clone https://github.com/jonatas-melo-silva/system-monitor.git
    ```

2. Navegue para o diretorio do projeto:

    ```bash
    cd system-monitor
    ```

3. de permissao de execucao ao script:

    ```bash
    chmod +x bin/system_monitor.sh
    ```

4. execute o script:

    ```bash
    ./bin/system_monitor.sh
    ```

## Dependências

Certifique-se de que as seguintes ferramentas estão instaladas no sistema:

- sensors
- free
- df
- uptime

Para instalar essas ferramentas em sistemas baseados em Debian, use:

```bash
sudo apt update && sudo apt install lm-sensors procps
```

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais detalhes.

## Autor

- **Jonatas Melo Silva** - *Desenvolvedor principal*

  Perfil no GitHub: jonatas-melo-silva

## Como contribuir

Contribuições são sempre bem-vindas! Para contribuir:

1. Faça um fork do repositório.

2. Crie uma branch para sua feature ou correção:

    ```bash
    git checkout -b minha-feature
    ```

3. Commit suas alterações:

    ```bash
    git commit -m "Adicionei uma nova feature"
    ```

4. Faça um push para a branch:

    ```bash
    git push origin minha-feature
    ```

5. Abra um Pull Request no repositório original.

Siga as melhores práticas para garantir que suas alterações sejam revisadas e aceitas rapidamente.
