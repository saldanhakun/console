#!/bin/bash
# lib/_args.sh - Auxiliares para tratamento de argumentos e ajuda

# Função para exibir ajuda padronizada
# Uso: _showHelp "Nome do Comando" "Descricao" "opcoes..."
_showHelp() {
    local cmdName="$1"
    local description="$2"
    shift 2
    
    echo -e "$(_color yellow "Uso:") $cmdName [opções]"
    echo ""
    echo "$description"
    echo ""
    echo -e "$(_color yellow "Opções:")"
    for opt in "$@"; do
        echo "  $opt"
    done
    echo "  --help    Exibe esta mensagem de ajuda"
}

# Função auxiliar para extrair valores de argumentos tipo --key=value
_getArgValue() {
    local arg="$1"
    echo "${arg#*=}"
}
