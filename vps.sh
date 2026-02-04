#!/bin/bash

# NÃO usar -u em script interativo
set -eo pipefail

# Fallback seguro
HOME="${HOME:-/root}"
VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

pause() {
    read -r -p "Pressione ENTER para continuar..."
}

header() {
    echo "===================================="
    echo " GERENCIADOR DE VPS / VM"
    echo "===================================="
}

menu() {
    while true; do
        header
        echo "1) Criar VM"
        echo "2) Iniciar VM"
        echo "0) Sair"
        echo
        read -r -p "Escolha uma opção: " op

        case "$op" in
            1)
                echo "Criar VM (teste)"
                pause
                ;;
            2)
                echo "Iniciar VM (teste)"
                pause
                ;;
            0)
                echo "Saindo..."
                exit 0
                ;;
            *)
                echo "Opção inválida"
                pause
                ;;
        esac
    done
}

menu
