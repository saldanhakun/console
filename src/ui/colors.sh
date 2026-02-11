#!/bin/bash
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
