#!/bin/bash
# lib/_core.sh - Detecção de sistema e utilitários básicos

_getDistro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

_isRoot() {
    [ "$EUID" -eq 0 ]
}

_hasSudo() {
    command -v sudo >/dev/null 2>&1
}

_runAsRoot() {
    if _isRoot; then
        "$@"
    elif _hasSudo; then
        sudo "$@"
    else
        _error "Este comando precisa de privilégios de root e sudo não foi encontrado."
        return 1
    fi
}

_isUbuntu() {
    [[ "$(_getDistro)" == "ubuntu" ]]
}

_isAlmaLinux() {
    [[ "$(_getDistro)" == "almalinux" ]]
}

_isRHELFamily() {
    local distro=$(_getDistro)
    [[ "$distro" == "almalinux" || "$distro" == "rocky" || "$distro" == "centos" || "$distro" == "fedora" || "$distro" == "rhel" ]]
}
