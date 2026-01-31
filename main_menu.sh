#!/usr/bin/env bash
set -u

# --- ANSI COLORS ---
C=$'\033[36m'  # Cyan
G=$'\033[32m'  # Green
R=$'\033[31m'  # Red
B=$'\033[34m'  # Blue
Y=$'\033[33m'  # Yellow
W=$'\033[97m'  # White
N=$'\033[0m'   # Reset

# --- HEADER FUNCTION ---
header() {
    clear
    echo -e "${B}  __  __       _         __  __                  ${N}"
    echo -e "${B} |  \/  | __ _(_)_ __   |  \/  | ___ _ __  _   _ ${N}"
    echo -e "${B} | |\/| |/ _\` | | '_ \  | |\/| |/ _ \ '_ \| | | |${N}"
    echo -e "${B} | |  | | (_| | | | | | | |  | |  __/ | | | |_| |${N}"
    echo -e "${B} |_|  |_|\__,_|_|_| |_| |_|  |_|\___|_| |_|\__,_|${N}"
    echo -e "${B}=====================================================${N}"
    echo -e "${Y}       Increava-se no canal srbugpocket!${N}
    echo -e "${Y}           Creditos:sagar gaming x2${N}
    echo -e "${B}=====================================================${N}"
    echo ""
}

# --- PAUSE FUNCTION ---
pause() {
    echo ""
    read -p "${W}Pressione [Enter] para voltar ao menu...${N}" dummy
}

# --- MAIN LOOP ---
while true; do
    header
    echo -e "${C} 1) ${W}instalar dependências ${G}(Node + Mineflayer)${N}"
    echo -e "${C} 2) ${W}Criador de Bot dc ${G}(Create app.js)${N}"
    echo -e "${C} 3) ${W}Reinicalização automatica ${G}(Systemd Service)${N}"
    echo -e "${C} 4) ${W}Remover Bot ${G}(Manager)${N}"
    echo -e "${C} 5) ${W}Servidor do Discord Link${N}"
    echo -e "${C} 6) ${W}Canal do youtube Link${N}"
    echo -e "${C} 7) ${W}instalar VM ${G}(IDX VPS)${N}"
    echo -e "${C} 8) ${W}Instalador de rdp ${G}(Desktop Environment)${N}"
    echo -e "${C} 9) ${W}Instalador Tailscale ${G}(VPN)${N}"
    echo -e "${R} 10) Sair${N}"
    echo ""
    echo -e "${B}=====================================================${N}"
    read -p "${Y}👉 selecione a opção [1-10]: ${N}" choice

    case $choice in
        1)
            echo ""
            echo -e "${Y}🔄 instalando dependências...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/dependency.sh | sed 's/\r$//' | bash
            pause
            ;;
        2)
            echo ""
            echo -e "${Y}🛠️  iniciando criador de Bot Dc...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/bot_maker.sh | sed 's/\r$//' | bash
            pause
            ;;
        3)
            echo ""
            echo -e "${Y}⚙️  iniciando reinicialização automatica...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/autorestarter.sh | sed 's/\r$//' | bash
            pause
            ;;
        4)
            echo ""
            echo -e "${Y}🚀 Remover Bot Dc...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/bot_remover.sh | sed 's/\r$//' | bash
            pause
            ;;
        5)
            echo ""
            echo -e "${B}📢 faça parte do servidor do discord!:${N}"
            echo -e "${G}🔗 https://discord.gg/WdWnkUpVwA${N}"
            echo ""
            pause
            ;;
        6)
            echo ""
            echo -e "${R}📺 Increva-se no YouTube:${N}"
            echo -e "${Y}🔗 https://www.youtube.com/@bugpocketgamer${N}"
            echo ""
            pause
            ;;
        7)
            echo ""
            echo -e "${Y}💻 Instalando VM (IDX VPS)...${N}"
            bash <(curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/vps.sh)
            pause
            ;;
        8)
            echo ""
            echo -e "${Y}🖥️  Instalando RDP...${N}"
            curl -fsSL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/rdp_installer.sh | sed 's/\r$//' | bash
            pause
            ;;
        9)
            echo ""
            echo -e "${Y}🌐 Instalando Tailscale VPN...${N}"
            curl -fsSL https://tailscale.com/install.sh | sh
            pause
            ;;
        10)
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
EOF
