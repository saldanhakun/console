#!/bin/bash
# lib/_ssh.sh - Gerenciamento de conexões SSH

_sshSync() {
    local sourceJson="${1:-$HOME/.console/ssh_hosts.json}"
    local configFile="$HOME/.ssh/config"
    local tmpFile=$(mktemp)
    
    if [ ! -f "$sourceJson" ]; then
        _error "Arquivo de origem JSON não encontrado: $sourceJson"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        _error "Ferramenta 'jq' não encontrada. Instale-a para processar JSON."
        return 1
    fi

    _info "Sincronizando configuração SSH de $sourceJson..."
    
    # Gera o bloco Toolbelt
    echo "### TOOLBELT START ###" > "$tmpFile"
    echo "# Gerado automaticamente - não edite manualmente entre as marcações" >> "$tmpFile"
    
    jq -r '.[] | "Host \(.alias)\n  HostName \(.host)\n  User \(.user)\n  Port \(.port)\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n"' "$sourceJson" >> "$tmpFile"
    
    echo "### TOOLBELT END ###" >> "$tmpFile"
    
    if [ ! -f "$configFile" ]; then
        mkdir -p "$(dirname "$configFile")"
        touch "$configFile"
        chmod 600 "$configFile"
    fi

    # Substitui o bloco se ele existir, ou anexa
    if grep -q "### TOOLBELT START ###" "$configFile"; then
        # Usa um arquivo temporário para a substituição segura
        local newConfig=$(mktemp)
        sed "/### TOOLBELT START ###/,/### TOOLBELT END ###/d" "$configFile" > "$newConfig"
        cat "$tmpFile" >> "$newConfig"
        mv "$newConfig" "$configFile"
    else
        cat "$tmpFile" >> "$configFile"
    fi
    
    rm "$tmpFile"
    _success "Configuração SSH atualizada com sucesso em $configFile."
}
