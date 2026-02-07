#!/bin/bash
set -euo pipefail

# =============================
# Gerenciador Avançado de Multi-VM
# =============================

display_header() {
    clear
    cat << "EOF"
========================================================================
BEM-VINDO AO CRIADOR DE VPS LINUX ❤️
========================================================================
EOF
    echo
}

print_status() {
    local type=$1
    local message=$2

    case $type in
        "INFO") echo -e "\033[1;34m[INFO]\033[0m $message" ;;
        "WARN") echo -e "\033[1;33m[AVISO]\033[0m $message" ;;
        "ERROR") echo -e "\033[1;31m[ERRO]\033[0m $message" ;;
        "SUCCESS") echo -e "\033[1;32m[SUCESSO]\033[0m $message" ;;
        "INPUT") echo -e "\033[1;36m[ENTRADA]\033[0m $message" ;;
        *) echo "[$type] $message" ;;
    esac
}

validate_input() {
    local type=$1
    local value=$2

    case $type in
        "number")
            [[ "$value" =~ ^[0-9]+$ ]] || {
                print_status "ERROR" "Deve ser um número"
                return 1
            }
            ;;
        "size")
            [[ "$value" =~ ^[0-9]+[GgMm]$ ]] || {
                print_status "ERROR" "Informe um tamanho válido (ex: 20G, 512M)"
                return 1
            }
            ;;
        "port")
            [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -ge 23 ] && [ "$value" -le 65535 ] || {
                print_status "ERROR" "Porta inválida (23–65535)"
                return 1
            }
            ;;
        "name")
            [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]] || {
                print_status "ERROR" "Nome inválido (use letras, números, - ou _)"
                return 1
            }
            ;;
        "username")
            [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]] || {
                print_status "ERROR" "Usuário inválido"
                return 1
            }
            ;;
    esac
}

check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img")
    local missing=()

    for d in "${deps[@]}"; do
        command -v "$d" &>/dev/null || missing+=("$d")
    done

    if [ ${#missing[@]} -ne 0 ]; then
        print_status "ERROR" "Dependências ausentes: ${missing[*]}"
        print_status "INFO" "Instale com: sudo apt install qemu-system cloud-image-utils wget"
        exit 1
    fi
}

cleanup() {
    rm -f user-data meta-data 2>/dev/null || true
}

get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

load_vm_config() {
    local vm_name=$1
    local cfg="$VM_DIR/$vm_name.conf"

    [[ -f "$cfg" ]] || {
        print_status "ERROR" "Configuração da VM '$vm_name' não encontrada"
        return 1
    }

    unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
    unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED

    source "$cfg"
}

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

    print_status "SUCCESS" "Configuração salva com sucesso"
}

# =============================
# CLOUD-INIT (NÃO TRADUZIR CHAVES)
# =============================
setup_vm_image() {
    print_status "INFO" "Preparando imagem da VM..."

    mkdir -p "$VM_DIR"

    if [[ ! -f "$IMG_FILE" ]]; then
        print_status "INFO" "Baixando imagem do sistema..."
        wget "$IMG_URL" -O "$IMG_FILE"
    fi

    qemu-img resize "$IMG_FILE" "$DISK_SIZE" || true

    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
ssh_pwauth: true
disable_root: false
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "$PASSWORD")
chpasswd:
  list: |
    root:$PASSWORD
    $USERNAME:$PASSWORD
  expire: false
EOF

    cat > meta-data <<EOF
instance-id: iid-$VM_NAME
local-hostname: $HOSTNAME
EOF

    cloud-localds "$SEED_FILE" user-data meta-data
    print_status "SUCCESS" "VM criada com sucesso"
}

# =============================
# MENU PRINCIPAL
# =============================
main_menu() {
    while true; do
        display_header

        local vms=($(get_vm_list))
        local total=${#vms[@]}

        if [ "$total" -gt 0 ]; then
            print_status "INFO" "VMs encontradas:"
            for i in "${!vms[@]}"; do
                echo " $((i+1))) ${vms[$i]}"
            done
            echo
        fi

        echo "Menu Principal:"
        echo " 1) Criar nova VM"
        echo " 2) Iniciar VM"
        echo " 3) Parar VM"
        echo " 4) Informações da VM"
        echo " 5) Editar VM"
        echo " 6) Excluir VM"
        echo " 0) Sair"

        read -p "$(print_status "INPUT" "Escolha uma opção: ")" op

        case $op in
            0)
                print_status "INFO" "Saindo..."
                exit 0
                ;;
            *)
                print_status "ERROR" "Opção inválida"
                ;;
        esac

        read -p "$(print_status "INPUT" "Pressione ENTER para continuar...")"
    done
}

trap cleanup EXIT

check_dependencies

VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

declare -A OS_OPTIONS=(
["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu22|ubuntu|ubuntu"
["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu24|ubuntu|ubuntu"
["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian12|debian|debian"
)

main_menu
