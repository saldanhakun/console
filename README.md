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

## Uso Modular

O projeto foi refatorado para usar uma estrutura modular com compilação:

```bash
# Compilar os módulos
./tools/compile.sh

# Usar um módulo compilado
source dist/ui.sh
_box @ success "Olá Mundo"
```

## Visão Geral do Diretório

- `src/`: Código fonte dos módulos (YAML, SH).
- `dist/`: Scripts compilados e prontos para uso.
- `tools/`: Ferramentas de build e desenvolvimento (ex: compilador).
- `tests/`: Baterias de testes unitários e funcionais.
- `bin/`: Contém executáveis independentes.
- `lib/`: Bibliotecas legadas (em processo de migração para `src/`).

## Como Estender

Para adicionar novas funcionalidades:

1.  Crie um novo arquivo em `lib/` com o prefixo `_` (ex: `lib/_docker.sh`).
2.  Defina suas funções usando o prefixo `_` (ex: `_dockerClean()`).
3.  As funções estarão automaticamente disponíveis ao carregar o `bootstrap.sh`.
4.  Se quiser um comando global, crie um script em `bin/` que carregue o `bootstrap.sh` e chame sua função.
