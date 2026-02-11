#!/bin/bash
# tests/ui.test.sh - Testes para o módulo UI

# Carrega o módulo compilado
source dist/ui.sh

# Teste de cores básicas (verifica se não dá erro)
_color green "Teste Verde" > /dev/null

# Teste de _strlen
[ "$(_strlen "Teste")" -eq 5 ]
[ "$(_strlen "$(_color blue "Teste")")" -eq 5 ]

# Teste de _repeat
[ "$(_repeat "#" 3)" == "###" ]

# Teste de tabelas
[ "$(_ui_table_ansiColors green)" == "0;32" ]
[ -n "$(_ui_table_utfIcons success)" ]

# Teste de _box (verifica se imprime algo)
box_out=$(_box "#" success "Linha 1" "Linha 2")
[ -n "$box_out" ]

# Teste de execução de comando
_run_ghost true
[ $? -eq 0 ]
_run_ghost false
[ $? -ne 0 ]

# Teste de bullet (silencioso no teste)
_run_bullet "Teste" true > /dev/null
[ $? -eq 0 ]

exit 0
