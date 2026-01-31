#!/usr/bin/env bash
# ==========================================
#   🚀 SAGAR GAMING 2X - FERRAMENTA COMPLETA
# ==========================================

set -u

# --- CORES ANSI ---
C=$'\033[36m'  # Ciano
G=$'\033[32m'  # Verde
R=$'\033[31m'  # Vermelho
B=$'\033[34m'  # Azul
Y=$'\033[33m'  # Amarelo
W=$'\033[97m'  # Branco
N=$'\033[0m'   # Resetar

# --- FUNÇÃO DE CABEÇALHO ---
cabecalho() {
    clear
    echo -e "${B}  __  __       _         __  __                  ${N}"
    echo -e "${B} |  \/  | __ _(_)_ __   |  \/  | ___ _ __  _   _ ${N}"
    echo -e "${B} | |\/| |/ _\` | | '_ \  | |\/| |/ _ \ '_ \| | | |${N}"
    echo -e "${B} | |  | | (_| | | | | | | |  | |  __/ | | | |_| |${N}"
    echo -e "${B} |_|  |_|\__,_|_|_| |_| |_|  |_|\___|_| |_|\__,_|${N}"
    echo -e "${B}=====================================================${N}"
    echo -e "${Y}        Inscreva-se no canal srbugpocket      ${N}"
    echo -e "${B}=====================================================${N}"
    echo ""
}

# --- FUNÇÃO DE PAUSA ---
pausa() {
    echo ""
    read -p "${W}Pressione [Enter] para voltar ao menu...${N}" dummy
}

# --- LOOP PRINCIPAL ---
while true; do
    cabecalho
    echo -e "${C} 1) ${W}Instalador de Dependências ${G}(Node + Mineflayer)${N}"
    echo -e "${C} 2) ${W}Criador de Bot ${G}(Criar app.js)${N}"
    echo -e "${C} 3) ${W}Configurar Reinício Automático ${G}(Serviço Systemd)${N}"
    echo -e "${C} 4) ${W}Remover Bot ${G}(Gerenciador)${N}"
    echo -e "${C} 5) ${W}Link do Servidor Discord${N}"
    echo -e "${C} 6) ${W}Link do Canal do YouTube${N}"
    echo -e "${C} 7) ${W}Instalador de VM ${G}(IDX VPS)${N}"
    echo -e "${C} 8) ${W}Instalador RDP ${G}(Ambiente de Desktop)${N}"
    echo -e "${C} 9) ${W}Instalador Tailscale ${G}(VPN)${N}"
    echo -e "${R} 10) Sair${N}"
    echo ""
    echo -e "${B}=====================================================${N}"
    read -p "${Y}👉 Selecione uma opção [1-10]: ${N}" escolha

    case $escolha in
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
            echo -e "${B}📢 faça parte do servidor do Discord!:${N}"
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
