# Console Toolbelt

Uma coleção robusta de funções e scripts Bash para administração de sistemas Linux, automação e monitoramento.

## Princípios Chave

- **Segurança Primeiro**: Funções internas são prefixadas com `_` (ex: `_color()`) para evitar colisões de nomes.
- **Modularidade**: Funções são agrupadas por afinidade. Você pode carregar apenas o que precisa.
- **Agnóstico ao Ambiente**: Compatível com Ubuntu e AlmaLinux (baseado em RHEL).
- **Focado em Automação**: Inclui ferramentas para gerenciamento de SSH, interações com API e monitoramento de saúde.

## Recursos Principais

- **UI Avançada**: Cores ANSI padronizadas e prompts interativos (`_ask`, `_confirm`).
- **Gerenciamento SSH**: Sincronização do `~/.ssh/config` a partir de uma fonte JSON para abstrair hostnames e portas complexas.
- **Monitoramento**: Verificações de saúde de baixo nível para stacks web (Nginx, MariaDB, PHP).
- **Sudo Inteligente**: Detecção automática de privilégios e elevação.
- **Argumentos Robustos**: Padronização de parsing de argumentos com suporte a `--help` e bash-completion.

## Uso

Para usar estas funções em seus scripts, carregue o arquivo `bootstrap.sh`:

```bash
source /path/to/console-toolbelt/bootstrap.sh

_info "Iniciando implantação..."
if _confirm "Deseja continuar?"; then
    _checkWebStack
fi
```

## Visão Geral do Diretório

- `bin/`: Contém executáveis independentes que delegam para funções da biblioteca.
- `lib/`: O coração do projeto. Carregue estes arquivos para ganhar acesso às funções `_`.
- `completions/`: Scripts para habilitar o preenchimento automático (Tab) para comandos customizados.

## Como Estender

Para adicionar novas funcionalidades:

1.  Crie um novo arquivo em `lib/` com o prefixo `_` (ex: `lib/_docker.sh`).
2.  Defina suas funções usando o prefixo `_` (ex: `_dockerClean()`).
3.  As funções estarão automaticamente disponíveis ao carregar o `bootstrap.sh`.
4.  Se quiser um comando global, crie um script em `bin/` que carregue o `bootstrap.sh` e chame sua função.
