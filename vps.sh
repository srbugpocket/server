#!/bin/bash

# Script interativo seguro
set -eo pipefail

HOME="${HOME:-/root}"
VM_DIR="${VM_DIR:-$HOME/vms}"
ISO_DIR="$VM_DIR/isos"

mkdir -p "$VM_DIR" "$ISO_DIR"

pause() {
    read -r -p "Pressione ENTER para continuar..."
}

header() {
    clear
    echo "===================================="
    echo "   GERENCIADOR DE VPS / VM (QEMU)"
    echo "===================================="
    echo
}

list_vms() {
    echo "VMs disponíveis:"
    ls "$VM_DIR"/*.qcow2 2>/dev/null | xargs -n1 basename | sed 's/.qcow2//' || echo "Nenhuma VM encontrada"
    echo
}

create_vm() {
    header
    read -r -p "Nome da VM: " name
    read -r -p "Tamanho do disco (GB): " size
    read -r -p "Memória (MB): " ram
    read -r -p "CPUs: " cpu
    read -r -p "Caminho da ISO: " iso

    vm_disk="$VM_DIR/$name.qcow2"

    if [[ -f "$vm_disk" ]]; then
        echo "❌ VM já existe!"
        pause
        return
    fi

    qemu-img create -f qcow2 "$vm_disk" "${size}G"

    echo "✅ VM criada com sucesso!"
    echo "Use 'Iniciar VM' para instalar o sistema."
    pause
}

start_vm() {
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

