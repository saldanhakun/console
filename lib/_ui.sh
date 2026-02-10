#!/bin/bash
# lib/_ui.sh - Funções de interface e cores

_color() {
    local colorName="$1"
    local message="$2"
    local raw=0
    
    [[ $colorName == @* ]] && { colorName=${colorName#@}; raw=1; }

    local colorCode="0;37"
    case "${colorName,,}" in
        black          ) colorCode='0;30' ;;
        red|error|danger) colorCode='0;31' ;;
        green|success  ) colorCode='0;32' ;;
        yellow|warning ) colorCode='0;33' ;;
        blue           ) colorCode='0;34' ;;
        magenta|input  ) colorCode='0;35' ;;
        cyan|info      ) colorCode='0;36' ;;
        white          ) colorCode='0;37' ;;
        bright_black   ) colorCode='0;90' ;;
        bright_red     ) colorCode='0;91' ;;
        bright_green   ) colorCode='0;92' ;;
        bright_yellow  ) colorCode='0;93' ;;
        bright_blue    ) colorCode='0;94' ;;
        bright_magenta ) colorCode='0;95' ;;
        bright_cyan    ) colorCode='0;96' ;;
        bright_white   ) colorCode='0;97' ;;
        gray|muted     ) colorCode='0;90' ;;
        *) colorCode='0;37' ;;
    esac

    if [ $raw -eq 1 ]; then
        echo -n "\[\\033[${colorCode}m\]${message}\[\\033[0m\]"
    else
        echo -en "\e[${colorCode}m${message}\e[0m"
    fi
}

_info()    { echo -e "$(_color info "[INFO]") $*"; }
_success() { echo -e "$(_color success "[SUCESSO]") $*"; }
_warn()    { echo -e "$(_color warning "[AVISO]") $*"; }
_error()   { echo -e "$(_color error "[ERRO]") $*" >&2; }

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
