#!/bin/bash
# lib/_monitor.sh - Verificações de saúde e manipulação de logs

_checkWebStack() {
    _info "Verificando a saúde do sistema..."
    
    local services=("nginx" "mariadb" "php-fpm")
    
    # Tenta detectar a versão do php-fpm instalada se php-fpm genérico não existir
    if ! systemctl list-unit-files | grep -q "^php-fpm.service"; then
        local php_service=$(systemctl list-unit-files | grep -o "php[0-9.]*-fpm.service" | head -n 1)
        if [ -n "$php_service" ]; then
            services=("nginx" "mariadb" "$php_service")
        fi
    fi

    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            _success "O serviço $service está rodando."
        else
            _error "O serviço $service está PARADO!"
        fi
    done
}

_filterLogByIp() {
    local logFile="$1"
    local ip="$2"
    local lines="${3:-50}"
    
    if [ ! -f "$logFile" ]; then
        _error "Arquivo de log não encontrado: $logFile"
        return 1
    fi
    
    _info "Filtrando as últimas $lines linhas de $logFile para o IP $ip..."
    grep "$ip" "$logFile" | tail -n "$lines"
}

_checkResources() {
    _info "Resumo de recursos do sistema:"
    echo "--- Carga do Sistema (Load Average) ---"
    cat /proc/loadavg | awk '{print "1 min: " $1 ", 5 min: " $2 ", 15 min: " $3}'
    echo "--- Memória ---"
    free -h | grep Mem | awk '{print "Total: " $2 ", Usado: " $3 ", Livre: " $4}'
    echo "--- Disco ---"
    df -h / | tail -n 1 | awk '{print "Uso de Disco (/): " $5}'
}
