#!/bin/bash
set -euo pipefail

# =============================
# Gerenciador Avançado de Múltiplas VMs
# =============================

# Função para exibir o cabeçalho
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

# Função para exibir mensagens coloridas
print_status() {
    local type=$1
    local message=$2

    case $type in
        "INFO") echo -e "\033[1;34m[INFO]\033[0m $message" ;;
        "WARN") echo -e "\033[1;33m[AVISO]\033[0m $message" ;;
        "CUIDADO") echo -e "\033[1;33m[CUIDADO]\033[0m $message" ;;
        "ERROR") echo -e "\033[1;31m[ERRO]\033[0m $message" ;;
        "SUCCESS") echo -e "\033[1;32m[SUCESSO]\033[0m $message" ;;
        "INPUT") echo -e "\033[1;36m[ENTRADA]\033[0m $message" ;;
        *) echo "[$type] $message" ;;
    esac
}

# Função para validar entradas
validate_input() {
    local type=$1
    local value=$2

    case $type in
        "number")
            [[ "$value" =~ ^[0-9]+$ ]] || { print_status "ERROR" "Digite um número válido"; return 1; }
            ;;
        "size")
            [[ "$value" =~ ^[0-9]+[GgMm]$ ]] || { print_status "ERROR" "Formato inválido (ex: 20G ou 512M)"; return 1; }
            ;;
        "port")
            [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -ge 23 ] && [ "$value" -le 65535 ] \
                || { print_status "ERROR" "Porta inválida (23–65535)"; return 1; }
            ;;
        "name")
            [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]] \
                || { print_status "ERROR" "Use apenas letras, números, hífen ou _"; return 1; }
            ;;
        "username")
            [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]] \
                || { print_status "ERROR" "Nome de usuário inválido"; return 1; }
            ;;
    esac
}

# Verificar dependências
check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img")
    local missing=()

    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done

    if [ ${#missing[@]} -ne 0 ]; then
        print_status "ERROR" "Dependências ausentes: ${missing[*]}"
        print_status "INFO" "No Ubuntu/Debian instale com:"
        print_status "INFO" "sudo apt install qemu-system cloud-image-utils wget"
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
    local config="$VM_DIR/$vm_name.conf"

    [[ -f "$config" ]] || { print_status "ERROR" "Configuração da VM não encontrada"; return 1; }
    source "$config"
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

create_new_vm() {
print_status "INFO" "Criando nova VM"

print_status "INFO" "Selecione o sistema operacional:"
local os_list=()
local i=1
for os in "${!OS_OPTIONS[@]}"; do
    echo " $i) $os"
    os_list[$i]="$os"
    ((i++))
done

while true; do
    read -p "Escolha uma opção: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ] && break
    print_status "ERROR" "Opção inválida"
done

IFS='|' read -r OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD <<< "${OS_OPTIONS[${os_list[$choice]}]}"

read -p "Nome da VM [$HOSTNAME]: " VM_NAME
VM_NAME="${VM_NAME:-$HOSTNAME}"

read -p "Tamanho do disco [20G]: " DISK_SIZE
DISK_SIZE="${DISK_SIZE:-20G}"

read -p "Memória RAM (MB) [2048]: " MEMORY
MEMORY="${MEMORY:-2048}"

read -p "Quantidade de CPUs [2]: " CPUS
CPUS="${CPUS:-2}"

read -p "Porta SSH [2222]: " SSH_PORT
SSH_PORT="${SSH_PORT:-2222}"

read -p "Ativar modo gráfico (GUI)? (y/N): " gui
GUI_MODE=false
[[ "$gui" =~ ^[Yy]$ ]] && GUI_MODE=true

read -p "Redirecionamento de portas (ex: 8080:80): " PORT_FORWARDS

IMG_FILE="$VM_DIR/$VM_NAME.img"
SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
CREATED="$(date)"

setup_vm_image
save_vm_config
}

setup_vm_image() {
print_status "INFO" "Preparando imagem da VM..."

mkdir -p "$VM_DIR"

if [[ ! -f "$IMG_FILE" ]]; then
    print_status "INFO" "Baixando imagem..."
    wget "$IMG_URL" -O "$IMG_FILE"
fi

qemu-img resize "$IMG_FILE" "$DISK_SIZE" || true

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

echo "instance-id: $VM_NAME" > meta-data
cloud-localds "$SEED_FILE" user-data meta-data

print_status "SUCCESS" "VM '$VM_NAME' criada com sucesso"
}

main_menu() {
while true; do
display_header

local vms=($(get_vm_list))
local count=${#vms[@]}

echo "Menu Principal"
echo "1) Criar nova VM"
[[ $count -gt 0 ]] && echo "2) Iniciar VM"
[[ $count -gt 0 ]] && echo "3) Parar VM"
[[ $count -gt 0 ]] && echo "4) Mostrar informações da VM"
[[ $count -gt 0 ]] && echo "5) Excluir VM"
echo "0) Sair"

read -p "Escolha uma opção: " op

case $op in
1) create_new_vm ;;
0) exit 0 ;;
*) print_status "WARN" "Opção inválida" ;;
esac

read -p "Pressione ENTER para continuar..."
done
}

trap cleanup EXIT
check_dependencies

VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

declare -A OS_OPTIONS=(
["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian|debian|debian"
)

main_menu


