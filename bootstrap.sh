#!/bin/bash
# bootstrap.sh - Carregador principal do Console Toolbelt

TOOLBELT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carrega todas as bibliotecas da pasta lib/
for lib in "$TOOLBELT_ROOT"/lib/_*.sh; do
    if [ -f "$lib" ]; then
        source "$lib"
    fi
done

# Caso o loop acima falhe por causa do wildcard (dependendo da versao do bash/config)
# carregamos explicitamente os principais se necessario
if ! declare -F _color > /dev/null; then
    source "$TOOLBELT_ROOT/lib/_ui.sh"
    source "$TOOLBELT_ROOT/lib/_core.sh"
    source "$TOOLBELT_ROOT/lib/_ssh.sh"
    source "$TOOLBELT_ROOT/lib/_monitor.sh"
    source "$TOOLBELT_ROOT/lib/_args.sh"
fi

export TOOLBELT_ROOT
