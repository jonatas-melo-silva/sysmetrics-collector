# SysMetrics Collector

Um script Bash para monitoramento contínuo de recursos do sistema, coletando métricas a cada 5 minutos e armazenando logs organizados por 7 dias em um diretório dedicado.

## Funcionalidades

- Monitoramento de CPU (modelo e frequência)
- Monitoramento de temperatura
- Uso de memória
- Tempo de atividade e carga do sistema
- Uso de disco
- Processos mais ativos
- Sistema de logs com rotação automática
- Limpeza automática de logs antigos

## Estrutura do Projeto

```plaintext
sysmetrics-collector/
├── README.md
├── LICENSE
├── install.sh
├── sysmetrics-collector.sh
└── src/
    ├── install/
    │   ├── root_checker.sh
    │   ├── package_installer.sh
    │   ├── sensors_config.sh
    │   └── permissions_setup.sh
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

## Requisitos

O script requer os seguintes pacotes:

- lm-sensors (monitoramento de temperatura)
- procps (informações de memória, processos e uptime)
- coreutils (informações de disco e utilitários básicos)
- util-linux (informações da CPU)
- grep (filtragem de saída)
- findutils (gerenciamento de logs)

## Instalação

1. Clone o repositório:

    ```bash
    git clone https://github.com/jonatas-melo-silva/sysmetrics-collector.git
    ```

2. Navegue para o diretorio do projeto:

    ```bash
    cd sysmetrics-collector
    ```

3. Garanta que o script install.sh tenha permissão de execução:

    ```bash
    chmod +x install.sh
    ```

4. Execute o script de instalação como root:

    ```bash
    sudo ./install.sh
    ```

O script de instalação irá:

- Verificar e instalar todas as dependências necessárias
- Configurar os sensores do sistema
- Configurar as permissões necessárias

## Uso

Para iniciar o monitoramento:
```bash
./system-monitor.sh
```

Por padrão, o sistema:

- Coleta métricas a cada 5 minutos
- Armazena logs em `$HOME/system_logs/`
- Mantém logs por 7 dias

## Configuração

As principais configurações podem ser ajustadas em `src/config/settings.sh`:

- `LOG_DIR`: Diretório onde os logs serão armazenados
- `MAX_DAYS`: Período de retenção dos logs
- `INTERVAL`: Intervalo entre coletas (em segundos)

## Carregamento de Configurações

Os arquivos de configuração implementam um sistema de proteção contra importações múltiplas:

- Cada arquivo de configuração pode ser importado várias vezes com segurança
- As variáveis readonly são definidas apenas na primeira importação
- O `PROJECT_ROOT` é preservado se já estiver definido
- As configurações são carregadas automaticamente pelos módulos que as necessitam

## Estrutura dos Módulos

- **config/**: Configurações e dependências

  - `settings.sh`: Configurações gerais do sistema
  - `dependencies.sh`: Definição das dependências necessárias

- **utils/**: Utilitários gerais

  - `logger.sh`: Funções de logging
  - `validators.sh`: Funções de validação

- **core/**: Funcionalidades principais

  - `collector.sh`: Coleta de métricas do sistema
  - `initializer.sh`: Inicialização do sistema
  - `cleanup.sh`: Limpeza e manutenção

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

- Cada módulo deve declarar suas próprias dependências
- Use as funções de logging para mensagens
- Exporte funções que serão usadas por outros módulos
- Mantenha o padrão de documentação nos cabeçalhos

## Autor

- **Jonatas Melo Silva** - *Desenvolvedor principal*

  Perfil no GitHub: [jonatas-melo-silva](https://github.com/jonatas-melo-silva)

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais detalhes.