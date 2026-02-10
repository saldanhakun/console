#!/bin/bash
# lib/_wp.sh - Integração simples com WP-CLI e utilitários Wordpress

_wp() {
    local wp_cli="/usr/local/bin/wp-cli.phar"
    
    if [ ! -f "$wp_cli" ]; then
        _error "WP-CLI não encontrado em $wp_cli"
        return 1
    fi

    if [ -f "$(pwd)/wp-config.php" ]; then
        local owner=$(stat -c %U "$(pwd)/wp-config.php")
        _info "Executando WP-CLI como usuário $owner..."
        sudo -u "$owner" php "$wp_cli" "$@"
    else
        php "$wp_cli" "$@"
    fi
}
