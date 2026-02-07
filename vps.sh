#!/bin/bash
set -euo pipefail

# =============================
# Enhanced Multi-VM Manager
# =============================

# ===== CORES E STATUS =====
print_status() {
    local type="$1"
    local message="$2"

    case "$type" in
        INFO)    echo -e "\033[1;34m[INFO]\033[0m $message" ;;
        AVISO)   echo -e "\033[1;33m[AVISO]\033[0m $message" ;;
        ERRO)    echo -e "\033[1;31m[ERRO]\033[0m $message" ;;
        SUCESSO) echo -e "\033[1;32m[SUCESSO]\033[0m $message" ;;
        *)       echo "[$type] $message" ;;
    esac
}

# ===== HEADER =====
display_header() {
    clear
    cat << "EOF"
========================================================================
Os criadores disso tudo são esses caras!
HOPINGBOYZ
Jishnu
NotGamerPie
========================================================================
EOF
    echo
}

# ===== VALIDAÇÃO =====
validate_input() {
    local type="$1"
    local value="$2"

    case "$type" in
        number)
            [[ "$value" =~ ^[0-9]+$ ]] || return 1
            ;;
        size)
            [[ "$value" =~ ^[0-9]+[GgMm]$ ]] || return 1
            ;;
        port)
            [[ "$value" =~ ^[0-9]+$ ]] && (( value >= 23 && value <= 65535 )) || return 1
            ;;
        name)
            [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]] || return 1
            ;;
        username)
            [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]] || return 1
            ;;
    esac
}

# ===== DEPENDÊNCIAS =====
check_dependencies() {
    local deps=(qemu-system-x86_64 qemu-img cloud-localds wget openssl ss)
    local missing=()

    for d in "${deps[@]}"; do
        command -v "$d" &>/dev/null || missing+=("$d")
    done

    if ((${#missing[@]} > 0)); then
        print_status ERRO "Dependências ausentes: ${missing[*]}"
        print_status INFO "Instale com: sudo apt install qemu-system cloud-image-utils wget openssl iproute2"
        exit 1
    fi
}

# ===== LIMPEZA =====
cleanup() {
    rm -f user-data meta-data 2>/dev/null || true
}
trap cleanup EXIT

# ===== DIRETÓRIO =====
VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

# ===== SISTEMAS =====
declare -A OS_OPTIONS=(
["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian|debian|debian"
)

# ===== LISTAR VMS =====
get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

# ===== LOAD CONFIG =====
load_vm_config() {
    local cfg="$VM_DIR/$1.conf"
    [[ -f "$cfg" ]] || return 1
    source "$cfg"
}

# ===== SAVE CONFIG =====
save_vm_config() {
    cat > "$VM_DIR/$VM_NAME.conf" <<EOF
VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
EOF
    print_status SUCESSO "Configuração salva"
}

# ===== CRIAR VM =====
create_new_vm() {
    print_status INFO "Criando nova VM"

    local keys=("${!OS_OPTIONS[@]}")
    for i in "${!keys[@]}"; do
        printf " %d) %s\n" $((i+1)) "${keys[$i]}"
    done

    while true; do
        read -p "Escolha o sistema: " opt
        ((opt>=1 && opt<=${#keys[@]})) || continue
        IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOST DEFAULT_USER DEFAULT_PASS <<< "${OS_OPTIONS[${keys[$((opt-1))]}]}"
        break
    done

    read -p "Nome da VM: " VM_NAME
    validate_input name "$VM_NAME" || { print_status ERRO "Nome inválido"; return; }

    HOSTNAME="$VM_NAME"
    read -p "Usuário [${DEFAULT_USER}]: " USERNAME
    USERNAME="${USERNAME:-$DEFAULT_USER}"

    read -s -p "Senha [${DEFAULT_PASS}]: " PASSWORD
    echo
    PASSWORD="${PASSWORD:-$DEFAULT_PASS}"

    read -p "Disco (20G): " DISK_SIZE
    DISK_SIZE="${DISK_SIZE:-20G}"

    read -p "RAM MB (2048): " MEMORY
    MEMORY="${MEMORY:-2048}"

    read -p "CPUs (2): " CPUS
    CPUS="${CPUS:-2}"

    read -p "Porta SSH (2222): " SSH_PORT
    SSH_PORT="${SSH_PORT:-2222}"

    IMG_FILE="$VM_DIR/$VM_NAME.qcow2"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"

    setup_vm_image
    save_vm_config
}

# ===== SETUP VM =====
setup_vm_image() {
    print_status INFO "Preparando imagem"

    wget -O "$IMG_FILE" "$IMG_URL"
    qemu-img resize "$IMG_FILE" "$DISK_SIZE"

    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
ssh_pwauth: true
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $(openssl passwd -6 "$PASSWORD")
EOF

    cat > meta-data <<EOF
instance-id: $VM_NAME
local-hostname: $HOSTNAME
EOF

    cloud-localds "$SEED_FILE" user-data meta-data
    print_status SUCESSO "VM criada com sucesso"
}

# ===== START VM =====
start_vm() {
    load_vm_config "$1" || return
    print_status INFO "Iniciando VM $VM_NAME"

    qemu-system-x86_64 \
        -enable-kvm \
        -m "$MEMORY" \
        -smp "$CPUS" \
        -drive file="$IMG_FILE",if=virtio \
        -drive file="$SEED_FILE",format=raw \
        -netdev user,id=n0,hostfwd=tcp::$SSH_PORT-:22 \
        -device virtio-net-pci,netdev=n0 \
        -nographic
}

# ===== MENU =====
main_menu() {
    while true; do
        display_header
        local vms=($(get_vm_list))

        echo "1) Criar VM"
        echo "2) Iniciar VM"
        echo "0) Sair"
        read -p "> " opt

        case "$opt" in
            1) create_new_vm ;;
            2)
                for i in "${!vms[@]}"; do
                    printf " %d) %s\n" $((i+1)) "${vms[$i]}"
                done
                read -p "Escolha: " n
                start_vm "${vms[$((n-1))]}"
                ;;
            0) exit 0 ;;
        esac
    done
}

check_dependencies
main_menu
