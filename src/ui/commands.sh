#!/bin/bash

_run_log="/tmp/_toolbelt_run"

_last_error() {
    [ -f "$_run_log.err" ] && cat "$_run_log.err" || echo ""
}

_last_output() {
    [ -f "$_run_log.out" ] && cat "$_run_log.out" || echo ""
}

_run_ghost() {
    # Suporte simplificado para redirecionamento
    local std="" err="" in=""
    
    # Esta é uma versão simplificada da lógica do lxc-initial-setup.sh
    # Para uma implementação completa de compilação, poderíamos expandir isso.
    
    "$@" > "$_run_log.out" 2> "$_run_log.err"
    local code=$?
    return $code
}

_run_bullet() {
    local label="$1"; shift
    echo -n "$(_icon bullet info) $label"
    _run_ghost "$@"
    local code=$?
    if [ $code -eq 0 ]; then
        echo " $(_icon tick success)"
    else
        echo " $(_icon times error)"
    fi
    return $code
}

_run_command() {
    local label="$1"; shift
    local clock=$SECONDS
    echo "$(_icon triangle-bullet info) $label:"
    _color muted "  $*"; echo ""
    _run_ghost "$@"
    local code=$?
    if [ $code -eq 0 ]; then
        _icon success success
        _color success " Executado com sucesso em $(( SECONDS - clock )) segundos"
    else
        _icon error error
        _color error " Execução falhou com código $code após $(( SECONDS - clock )) segundos"
        [ -s "$_run_log.err" ] && _color yellow "\n$(_last_error)"
    fi
    echo ""
    return $code
}
