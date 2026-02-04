#!/bin/bash
set -euo pipefail

# ==========================================
# GERENCIADOR AVANÇADO DE VMs QEMU/KVM
# ==========================================

# Garantir modo interativo mesmo fora de TTY
if [[ ! -t 0 ]]; then
    exec < /dev/tty
fi

# Diretório das VMs
VM_DIR="${VM_DIR:-$HOME/vms}"

# =============================
# FUNÇÕES VISUAIS
# =============================

mostrar_cabecalho() {
    clear
    cat << "EOF"
==============================================================
 GERENCIADOR DE VMS - QEMU
 Criadores:
  - HOPINGBOYZ
  - Jishnu
  - NotGamerPie
==============================================================
EOF
    echo
}

status() {
    local tipo="$1"
    local msg="$2"

    case "$tipo" in
        INFO) echo -e "\033[1;34m[INFO]\033[0m $msg" ;;
        AVISO) echo -e "\033[1;33m[AVISO]\033[0m $msg" ;;
        ERRO) echo -e "\033[1;31m[ERRO]\033[0m $msg" ;;
        OK) echo -e "\033[1;32m[OK]\033[0m $msg" ;;
        *) echo "$msg" ;;
    esac
}

# =============================
# DEPENDÊNCIAS
# =============================

checar_dependencias() {
    local deps=(qemu-system-x86_64 qemu-img cloud-localds wget openssl)
    for d in "${deps[@]}"; do
        if ! command -v "$d" &>/dev/null; then
            status ERRO "Dependência ausente: $d"
            status INFO "Instale com: sudo apt install qemu-system cloud-image-utils wget openssl"
            exit 1
        fi
    done
}

# =============================
# DETECÇÃO KVM
# =============================

SUPORTE_KVM=false
if [[ -e /dev/kvm ]]; then
    SUPORTE_KVM=true
fi

# =============================
# SISTEMAS SUPORTADOS
# =============================

declare -A SISTEMAS=(
["Ubuntu 22.04"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
["Ubuntu 24.04"]="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
["Debian 11"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
["Debian 12"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
["Fedora 40"]="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40.x86_64.qcow2"
["AlmaLinux 9"]="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
["Rocky Linux 9"]="https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
)

# =============================
# CRIAR VM
# =============================

criar_vm() {
    mostrar_cabecalho
    status INFO "Criando nova VM"

    echo "Escolha o sistema operacional:"
    local i=1
    local lista=()
    for so in "${!SISTEMAS[@]}"; do
        echo " $i) $so"
        lista[$i]="$so"
        ((i++))
    done

    read -r escolha < /dev/tty
    SO="${lista[$escolha]}"
    IMG_URL="${SISTEMAS[$SO]}"

    read -p "Nome da VM: " VM
    read -p "Usuário: " USUARIO
    read -s -p "Senha: " SENHA
    echo
    read -p "RAM (MB, mínimo 512): " RAM
    read -p "CPUs: " CPU
    read -p "Disco (ex: 20G): " DISCO
    read -p "Porta SSH (ex: 2222): " PORTA

    RAM=${RAM:-1024}
    (( RAM < 512 )) && RAM=512

    mkdir -p "$VM_DIR/$VM"

    IMG="$VM_DIR/$VM/disk.qcow2"
    SEED="$VM_DIR/$VM/seed.iso"

    status INFO "Baixando imagem..."
    wget -O "$IMG" "$IMG_URL"

    qemu-img resize "$IMG" "$DISCO"

    cat > user-data <<EOF
#cloud-config
hostname: $VM
users:
  - name: $USUARIO
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $(openssl passwd -6 "$SENHA")
ssh_pwauth: true
EOF

    cat > meta-data <<EOF
instance-id: $VM
local-hostname: $VM
EOF

    cloud-localds "$SEED" user-data meta-data
    rm -f user-data meta-data

    status OK "VM criada com sucesso!"
}

# =============================
# INICIAR VM
# =============================

iniciar_vm() {
    read -p "Nome da VM: " VM
    IMG="$VM_DIR/$VM/disk.qcow2"
    SEED="$VM_DIR/$VM/seed.iso"

    [[ ! -f "$IMG" ]] && status ERRO "VM não encontrada" && return

    if $SUPORTE_KVM; then
        ACEL="-enable-kvm -cpu host"
    else
        status AVISO "KVM não disponível, usando emulação"
        ACEL="-cpu max"
    fi

    qemu-system-x86_64 \
        $ACEL \
        -m 1024 \
        -smp 2 \
        -drive file="$IMG",if=virtio \
        -drive file="$SEED",format=raw,if=virtio \
        -netdev user,id=net0,hostfwd=tcp::2222-:22 \
        -device virtio-net-pci,netdev=net0 \
        -nographic
}

# =============================
# MENU
# =============================

menu() {
    while true; do
        mostrar_cabecalho
        echo "1) Criar VM"
        echo "2) Iniciar VM"
        echo "0) Sair"
        read -r opcao < /dev/tty

        case "$opcao" in
            1) criar_vm ;;
            2) iniciar_vm ;;
            0) exit 0 ;;
            *) status ERRO "Opção inválida" ;;
        esac

        read -p "Pressione ENTER para continuar..." < /dev/tty
    done
}

# =============================
# INÍCIO
# =============================

checar_dependencias
menu

