#!/bin/bash
# tests/runner.sh - Executor de testes para o Console Toolbelt

set -e

DIST_DIR="dist"
TEST_DIR="tests"

# Cores para o runner
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

run_test() {
    local test_file="$1"
    echo -n "Rodando $(basename "$test_file")... "
    if bash "$test_file" &> /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        # Se falhar, roda de novo sem silenciar para mostrar o erro
        bash "$test_file"
        exit 1
    fi
}

echo "Iniciando bateria de testes..."

for t in "$TEST_DIR"/*.test.sh; do
    if [ -f "$t" ]; then
        run_test "$t"
    fi
done

echo "Todos os testes passaram!"
