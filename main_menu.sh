#!/usr/bin/env bash
set -u

# --- ANSI COLORS ---
C=$'\033[36m'  # Ciano
G=$'\033[32m'  # Verde
R=$'\033[31m'  # Vermelho
B=$'\033[34m'  # Azul
Y=$'\033[33m'  # Amarelo
W=$'\033[97m'  # Branco
N=$'\033[0m'   # Reset

# --- MENU ---
header() {
    clear
    echo -e "${B}=====================================================${N}"
    echo -e "${Y}       Increva-se no canal srbugpocket!${N}"
    echo -e "${B}=====================================================${N}"
    echo ""
}

# --- Função PAUSAR ---
pause() {
    echo ""
    read -p "${W}Pressione [Enter] para voltar ao menu...${N}" dummy
}

# --- MAIN LOOP ---
while true; do
    header
    echo -e "${C} 1) ${W}Servidor do Discord${N}"
    echo -e "${C} 2) ${W}Canal do YouTube${N}"
    echo -e "${C} 3) ${W}VM Manager ${G}(IDX VPS)${N}"
    echo -e "${C} 4) ${W}Instalador de RDP ${G}(Desktop Environment)${N}"
    echo -e "${R} 5) Sair${N}"
    echo ""
    echo -e "${B}=====================================================${N}"
    read -p "${Y}👉 selecione a opção [1-10]: ${N}" choice

    case $choice in
        1)
            echo ""
            echo -e "${B}📢 faça parte do servidor do Discord!:${N}"
            echo -e "${G}🔗 https://discord.gg/WdWnkUpVwA${N}"
            echo ""
            pause
            ;;
        2)
            echo ""
            echo -e "${R}📺 Increva-se no YouTube:${N}"
            echo -e "${Y}🔗 https://www.youtube.com/@bugpocketgamer${N}"
            echo ""
            pause
            ;;
        3)
            echo ""
            echo -e "${Y}💻 Acessando VM manager (IDX VPS)...${N}"
            bash <(curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/Vm%20Manager.sh)
            pause
            ;;
        4)
            echo ""
            echo -e "${Y}🖥️  Instalando RDP...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/instalador_rdp.sh | sed 's/\r$//' | bash
            pause
            ;;
        5)
            echo ""
            echo -e "${G}👋 Saindo... ${N}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${R}❌ Opção errada! por favor coloque a opção correta! 1-10.${N}"
            sleep 2
            ;;
    esac
done
