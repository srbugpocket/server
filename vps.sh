#!/usr/bin/env bash
set -eo pipefail

# garante TTY mesmo via curl | bash
if [ ! -t 0 ]; then
    exec </dev/tty
fi

HOME="${HOME:-/root}"
VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

pause() {
    read -r -p "Pressione ENTER para continuar..." </dev/tty
}

header() {
    echo "===================================="
    echo " GERENCIADOR DE VPS / VM"
    echo "===================================="
    echo
}

menu() {
    while true; do
        header
        echo "1) Criar VM"
        echo "2) Iniciar VM"
        echo "0) Sair"
        echo

        read -r -p "Escolha uma opção: " op </dev/tty

        case "$op" in
            1)
                echo "Criar VM (placeholder)"
                pause
                ;;
            2)
                echo "Iniciar VM (placeholder)"
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
        clear
    done
}

menu
tart_vm() {
    header
    list_vms
    read -r -p "Nome da VM para iniciar: " name

    vm_disk="$VM_DIR/$name.qcow2"

    if [[ ! -f "$vm_disk" ]]; then
        echo "❌ VM não encontrada!"
        pause
        return
    fi

    qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -smp 2 \
        -drive file="$vm_disk",format=qcow2 \
        -net nic -net user \
        -display default &

    echo "🚀 VM iniciada!"
    pause
}

delete_vm() {
    header
    list_vms
    read -r -p "Nome da VM para deletar: " name

    vm_disk="$VM_DIR/$name.qcow2"

    if [[ ! -f "$vm_disk" ]]; then
        echo "❌ VM não encontrada!"
        pause
        return
    fi

    read -r -p "Tem certeza? (s/N): " confirm
    if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
        rm -f "$vm_disk"
        echo "🗑️ VM removida!"
    else
        echo "Cancelado."
    fi
    pause
}

menu() {
    while true; do
        header
        echo "1) Criar VM"
        echo "2) Iniciar VM"
        echo "3) Listar VMs"
        echo "4) Deletar VM"
        echo "0) Sair"
        echo
        read -r -p "Escolha uma opção: " op

        case "$op" in
            1) create_vm ;;
            2) start_vm ;;
            3) header; list_vms; pause ;;
            4) delete_vm ;;
            0) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida"; pause ;;
        esac
    done
}

menu

