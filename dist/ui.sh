#!/bin/bash
# Módulo: Interface com Usuário
# Descrição: Definições de sintaxe para a interface com usuário
# GERADO AUTOMATICAMENTE - NÃO EDITE ESTE ARQUIVO DIRETAMENTE

# --- Tabelas de Dados ---
function _ui_table_ansiColors() {
    case "$1" in
        black) echo -n "0;30" ;;
        red) echo -n "0;31" ;;
        error) echo -n "0;31" ;;
        danger) echo -n "0;31" ;;
        green) echo -n "0;32" ;;
        success) echo -n "0;32" ;;
        yellow) echo -n "0;33" ;;
        warning) echo -n "0;33" ;;
        blue) echo -n "0;34" ;;
        magenta) echo -n "0;35" ;;
        input) echo -n "0;35" ;;
        cyan) echo -n "0;36" ;;
        info) echo -n "0;36" ;;
        white) echo -n "0;37" ;;
        bright_black) echo -n "0;90" ;;
        bright_red) echo -n "0;91" ;;
        bright_green) echo -n "0;92" ;;
        bright_yellow) echo -n "0;93" ;;
        bright_blue) echo -n "0;94" ;;
        bright_magenta) echo -n "0;95" ;;
        bright_cyan) echo -n "0;96" ;;
        bright_white) echo -n "0;97" ;;
        gray) echo -n "0;90" ;;
        muted) echo -n "0;90" ;;
    esac
}
function _ui_table_utfIcons() {
    case "$1" in
        success) echo -n "✅ " ;;
        error) echo -n "❌ " ;;
        alert) echo -n "⚠ " ;;
        info) echo -n "ℹ " ;;
        launch) echo -n "Ὠ0 " ;;
        idea) echo -n "Ὂ1 " ;;
        nice) echo -n "ὄd " ;;
        bad) echo -n "ὄe " ;;
        fire) echo -n "ὒ5 " ;;
        forbidden) echo -n "Ὢ8 " ;;
        smile) echo -n "ὠ0 " ;;
        tick) echo -n "✓ " ;;
        times) echo -n "✖ " ;;
        arrow-right) echo -n "→ " ;;
        arrow-left) echo -n "← " ;;
        arrow-right-double) echo -n "⇒ " ;;
        arrow-left-double) echo -n "⇐ " ;;
        cog) echo -n "⚙ " ;;
        star) echo -n "★ " ;;
        clock) echo -n "⏱ " ;;
        bullet) echo -n "● " ;;
        triangle-bullet) echo -n "‣ " ;;
    esac
}

# --- Implementação Privada ---

_ask() {
    local prompt="$1"
    local default="$2"
    local response
    echo -en "$(_color input "$prompt") [${default}]: "
    read response
    echo "${response:-$default}"
}

_confirm() {
    local prompt="$1"
    local response
    echo -en "$(_color input "$prompt") [s/N]: "
    read -n 1 response
    echo
    [[ "$response" =~ ^[Ss]$ ]]
}

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

# --- Implementação Pública ---
# lib/_ui.sh - Funções de interface e cores

_color() {
    local colorName="$1"
    local message="$2"
    local raw=0
    
    [[ $colorName == @* ]] && { colorName=${colorName#@}; raw=1; }

    local colorCode=$(_ui_table_ansiColors "${colorName,,}")
    [ -z "$colorCode" ] && colorCode="0;37"

    if [ $raw -eq 1 ]; then
        echo -n "\[\\033[${colorCode}m\]${message}\[\\033[0m\]"
    else
        echo -en "\e[${colorCode}m${message}\e[0m"
    fi
}

_icon() {
    local iconName="$1"
    local colorName="$2"
    local icon=$(_ui_table_utfIcons "$iconName")
    
    [ -z "$icon" ] && icon=$(_ui_table_utfIcons "color-$iconName") # Compatibilidade com prefixo color-
    [ -z "$icon" ] && icon="$iconName"

    if [ -n "$colorName" ]; then
        _color "$colorName" "$icon"
    else
        echo -en "$icon"
    fi
}

_strlen() {
    local text="$(echo -n "$@" | sed 's/\x1b\[[0-9;]*m//g')"
    if [[ $LANG == *UTF-8 ]]; then
        echo ${#text}
    else
        echo -n "$text" | wc -m
    fi
}

_repeat() {
    local char="$1"
    local count="$2"
    local colorName="$3"
    local rep
    printf -v rep '%*s' "$count" ""
    if [ -n "$colorName" ]; then
        _color "$colorName" "${rep// /$char}"
    else
        echo -n "${rep// /$char}"
    fi
}

_box() {
    local wall="$1"; shift
    local colorName="$1"; shift
    local larger=0
    local thick=1
    
    if [ "$(_strlen "$wall")" -gt 1 ]; then
        thick=${wall:1:1}
        wall=${wall:0:1}
    fi
    
    local side=$(_repeat "$wall" "$thick" "$colorName")
    
    for line in "$@"; do
        local len=$(_strlen "$line")
        [ "$len" -gt "$larger" ] && larger="$len"
    done
    
    local bar=$(_repeat "$wall" "$(( larger + 2 + thick + thick ))" "$colorName")
    
    echo -e "\n${bar}"
    for line in "$@"; do
        local msg="$(printf "%-${larger}s" "$line")"
        local len=$(_strlen "$msg")
        [ "$len" -lt "$larger" ] && msg="$msg$(_repeat ' ' $(( larger - len )))"
        echo -en "$side "; echo -n "$msg"; echo -e " $side"
    done
    echo -e "$bar\n"
}

_under() {
    local msg="$1"
    local char="${2:--}"
    local colorName="${3:-none}"
    echo -e "\n$msg"
    _repeat "${char:0:1}" "$(_strlen "$msg")" "$colorName"
    echo -e "\n"
}

_info()    { echo -e "$(_icon info info) $(_color info "[INFO]") $*"; }
_success() { echo -e "$(_icon success success) $(_color success "[SUCESSO]") $*"; }
_warn()    { echo -e "$(_icon alert warning) $(_color warning "[AVISO]") $*"; }
_error()   { echo -e "$(_icon error error) $(_color error "[ERRO]") $*" >&2; }
# --- Helpers de Argumentos ---
function ui.color() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _color "$@"
}
function ui.success() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _success "$@"
}
function ui.error() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _error "$@"
}
function ui.warning() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _warning "$@"
}
function ui.info() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _info "$@"
}
function ui.ask() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _ask "$@"
}
function ui.confirm() {
    if [[ "$1" == "--help" ]]; then
        return 0
    fi
    _confirm "$@"
}
