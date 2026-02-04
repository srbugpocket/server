#!/usr/bin/env bash
set -e

while true; do
    echo "=========================="
    echo " GERENCIADOR VM"
    echo "=========================="
    echo "1) Teste"
    echo "0) Sair"
    echo

    read -p "Opção: " op || exit 0

    case "$op" in
        1) echo "Funcionando"; read -p "ENTER";;
        0) exit 0;;
        *) echo "Inválido";;
    esac
done


