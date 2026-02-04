#!/usr/bin/env bash
set -euo pipefail

# ==========================================
#   SAFE QEMU/KVM VM MANAGER (MULTI IMAGES)
# ==========================================

# ---- COLORS ----
C=$'\033[36m'
G=$'\033[32m'
R=$'\033[31m'
Y=$'\033[33m'
N=$'\033[0m'

BASE_DIR="$HOME/vms"
IMG_DIR="$BASE_DIR/images"
VM_DIR="$BASE_DIR/instances"

mkdir -p "$IMG_DIR" "$VM_DIR"

print_ok()   { echo "${G}[OK]${N} $1"; }
print_warn() { echo "${Y}[WARN]${N} $1"; }
print_err()  { echo "${R}[ERRO]${N} $1"; }

# ---- SYSTEM CHECKS ----
MAX_RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)

USE_KVM=false
if [[ -e /dev/kvm ]]; then
    USE_KVM=true
    print_ok "KVM disponível"
else
    print_warn "KVM não disponível (emulação será usada)"
fi

# ---- IMAGES ----
declare -A IMAGES=(
    ["ubuntu20"]="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
    ["ubuntu22"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    ["debian11"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
    ["debian12"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    ["fedora"]="https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
    ["almalinux"]="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
)

download_image() {
    local name="$1"
    local url="$2"
    local img="$IMG_DIR/$name.qcow2"

    if [[ -f "$img" ]]; then
        print_ok "Imagem $name já existe"
        return
    fi

    print_ok "Baixando imagem $name..."
    if wget "$url" -O "$img.tmp"; then
        mv "$img.tmp" "$img"
        print_ok "Imagem $name pronta"
    else
        rm -f "$img.tmp"
        print_err "Falha ao baixar $name"
        exit 1
    fi
}

# ---- CREATE VM ----
create_vm() {
    echo "Imagens disponíveis:"
    select IMG_KEY in "${!IMAGES[@]}"; do
        [[ -n "$IMG_KEY" ]] && break
    done

    download_image "$IMG_KEY" "${IMAGES[$IMG_KEY]}"

    read -rp "Nome da VM: " VM_NAME
    read -rp "RAM (MB) [max $MAX_RAM_MB]: " MEMORY
    read -rp "CPUs: " CPUS
    read -rp "Porta SSH externa: " SSH_PORT

    if (( MEMORY >= MAX_RAM_MB )); then
        print_err "RAM excede limite da VPS"
        exit 1
    fi

    VM_PATH="$VM_DIR/$VM_NAME"
    mkdir -p "$VM_PATH"

    BASE_IMG="$IMG_DIR/$IMG_KEY.qcow2"
    DISK="$VM_PATH/disk.qcow2"

    qemu-img create -f qcow2 -b "$BASE_IMG" "$DISK" 20G

    cat > "$VM_PATH/cloud-init.yml" <<EOF
#cloud-config
users:
  - name: vmuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    plain_text_passwd: senha123
    lock_passwd: false
ssh_pwauth: true
EOF

    cloud-localds "$VM_PATH/seed.img" "$VM_PATH/cloud-init.yml"

    CMD=(
        qemu-system-x86_64
        -m "$MEMORY"
        -smp "$CPUS"
        -drive file="$DISK",if=virtio
        -drive file="$VM_PATH/seed.img",format=raw
        -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22
        -device virtio-net-pci,netdev=n0
        -nographic
    )

    if $USE_KVM; then
        CMD+=(-enable-kvm -cpu host)
    else
        CMD+=(-cpu qemu64)
    fi

    print_ok "Iniciando VM em background..."
    nohup "${CMD[@]}" > "$VM_PATH/vm.log" 2>&1 &

    echo $! > "$VM_PATH/vm.pid"
    print_ok "VM $VM_NAME rodando (PID $(cat "$VM_PATH/vm.pid"))"
}

# ---- STOP VM ----
stop_vm() {
    read -rp "Nome da VM: " VM_NAME
    PID_FILE="$VM_DIR/$VM_NAME/vm.pid"

    [[ ! -f "$PID_FILE" ]] && print_err "VM não encontrada" && return

    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    print_ok "VM parada"
}

# ---- MENU ----
while true; do
    echo
    echo "1) Criar VM"
    echo "2) Parar VM"
    echo "3) Sair"
    read -rp "> " OP

    case "$OP" in
        1) create_vm ;;
        2) stop_vm ;;
        3) exit ;;
        *) print_warn "Opção inválida" ;;
    esac
done
