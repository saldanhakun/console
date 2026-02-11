#!/bin/bash

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
