#!/usr/bin/env bash
# ==============================================================================
#  LXC/LXD AUTOMATED INSTALLER (ASCII FIX)
#  Author:  NotGamerPie
#  License: MIT
# ==============================================================================

set -euo pipefail

# --- Configuration ---
LOG_FILE="/var/log/lxd_install.log"
export DEBIAN_FRONTEND=noninteractive
TOTAL_STEPS=6
CURRENT_STEP=1

# --- Colors & Styles ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# --- Visual Utilities ---

hide_cursor() { tput civis; }
show_cursor() { tput cnorm; }
trap 'show_cursor; echo -e "${NC}"; exit' INT TERM EXIT

# Typewriter Effect
type_text() {
    local text="$1"
    local delay=0.01
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

draw_header() {
    clear
    echo -e "${CYAN}${BOLD}"
# -----------------------------------------------------------------
# FIX: Using 'EOF' (single quotes) prevents backslash breakage
# -----------------------------------------------------------------
cat << 'EOF'
  _   _       _   ____                           ____  _      
 | \ | | ___ | |_/ ___| __ _ _ __ ___   ___ _ __|  _ \(_) ___ 
 |  \| |/ _ \| __| |  _ / _` | '_ ` _ \ / _ \ '__| |_) | |/ _ \
 | |\  | (_) | |_| |_| | (_| | | | | | |  __/ |  |  __/| |  __/
 |_| \_|\___/ \__|\____|\__,_|_| |_| |_|\___|_|  |_|   |_|\___|

EOF
    echo -e "${BLUE}   :: LXC/LXD DEPLOYMENT SUITE ::${NC}"
    echo -e "${DIM}      Maintained by NotGamerPie${NC}"
    echo -e "\n"
}

# Progress Bar
progress_bar() {
    local duration=${1}
    local label="${2}"
    local width=40
    local filled
    local unfilled
    local bar
    
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}]${NC} ${BOLD}${label}${NC}"
    local sleep_interval=$(awk "BEGIN {print $duration / 100}")
    
    for ((i=0; i<=100; i+=2)); do
        filled=$((i * width / 100))
        unfilled=$((width - filled))
        bar=$(printf "%${filled}s" | tr ' ' '█')
        empty=$(printf "%${unfilled}s" | tr ' ' '·')
        
        local color=$RED
        if [ $i -gt 50 ]; then color=$YELLOW; fi
        if [ $i -eq 100 ]; then color=$GREEN; fi
        
        echo -ne "\r${BLUE}[${color}${bar}${DIM}${empty}${BLUE}]${NC} ${color}${i}%${NC}"
        sleep "$sleep_interval"
    done
    echo -e "\n"
    ((CURRENT_STEP++))
}

# Real-Time Task Runner
run_task() {
    local label="$1"
    shift
    local command=("$@")
    
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local temp
    local start_ts=$(date +%s)
    
    # Run command in background
    "${command[@]}" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # Spinner Loop with Live Timer
    while kill -0 "$pid" 2>/dev/null; do
        local cur_ts=$(date +%s)
        local elapsed=$((cur_ts - start_ts))
        
        temp="${spinstr#?}"
        # Reprint line with live timer
        printf "\r${CYAN}   ::${NC} ${label}... [${PURPLE}%c${NC}] ${DIM}%02ds${NC}" "$spinstr" "$elapsed"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
    done
    
    wait "$pid"
    local exit_code=$?
    local end_ts=$(date +%s)
    local total_elapsed=$((end_ts - start_ts))
    
    # Final Status with Total Time
    if [ $exit_code -eq 0 ]; then
        printf "\r${CYAN}   ::${NC} ${label}... [${GREEN}✔${NC}] ${DIM}${total_elapsed}s${NC}   \n"
    else
        printf "\r${CYAN}   ::${NC} ${label}... [${RED}✘${NC}] ${DIM}${total_elapsed}s${NC}   \n"
        echo -e "\n${RED}Error executing: ${label}${NC}"
        echo -e "${YELLOW}Last 3 log lines:${NC}"
        tail -n 3 "$LOG_FILE"
        exit 1
    fi
}

# --- Core Logic ---

init_setup() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[ERROR] This script requires sudo permissions.${NC}"
        exit 1
    fi
    
    # Reset bash internal timer
    SECONDS=0
    
    draw_header
    > "$LOG_FILE"
    
    # Clean locks if any
    if fuser /var/lib/dpkg/lock >/dev/null 2>&1; then
        fuser -k /var/lib/dpkg/lock >/dev/null 2>&1 || true
        rm -f /var/lib/dpkg/lock
    fi

    progress_bar 1 "Initializing Installer Environment"
}

detect_os() {
    progress_bar 1 "Analyzing Operating System"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "      ${DIM}Detected:${NC} ${GREEN}$PRETTY_NAME${NC}"
        sleep 0.5
    else
        echo -e "${RED}[ERROR] Unsupported OS.${NC}"
        exit 1
    fi
}

install_updates() {
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}]${NC} ${BOLD}System Preparation${NC}"
    
    local APT_OPTS="-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
    
    run_task "Updating Apt Repositories" apt-get update $APT_OPTS
    run_task "Installing Core Tools" apt-get install $APT_OPTS curl wget
    run_task "Installing Network Utils" apt-get install $APT_OPTS bridge-utils
    echo ""
    ((CURRENT_STEP++))
}

install_lxd() {
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}]${NC} ${BOLD}Deploying LXD Container Engine${NC}"
    
    if ! command -v snap >/dev/null 2>&1; then
        run_task "Installing Snap Daemon" apt-get install -y snapd
        run_task "Activating Snap Socket" systemctl enable --now snapd.socket
    fi

    if ! snap list lxd >/dev/null 2>&1; then
        run_task "Waiting for Seed Load" snap wait system seed.loaded
        run_task "Downloading LXD (Stable)" snap install lxd --channel=latest/stable
    else
        echo -e "      ${DIM}LXD is already installed.${NC}"
    fi

    if ! echo "$PATH" | grep -q "/snap/bin"; then
        export PATH=$PATH:/snap/bin
    fi
    echo ""
    ((CURRENT_STEP++))
}

configure_user() {
    progress_bar 1 "Configuring User Permissions"
    local target_user="${SUDO_USER:-$(whoami)}"
    
    if [ "$target_user" != "root" ]; then
        if ! groups "$target_user" | grep -q "\blxd\b"; then
            run_task "Adding $target_user to 'lxd' group" usermod -aG lxd "$target_user"
        else
             echo -e "      ${DIM}User $target_user already authorized.${NC}"
        fi
    fi
}

init_config() {
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}]${NC} ${BOLD}LXD Initialization${NC}"
    echo -e "${YELLOW}      Interactive Mode: Press ENTER to accept defaults.${NC}"
    
    lxd init
    
    echo ""
    run_task "Verifying Service Health" lxc info
    ((CURRENT_STEP++))
}

finish() {
    # Calculate Total Time
    local total_seconds=$SECONDS
    local mins=$((total_seconds / 60))
    local secs=$((total_seconds % 60))
    
    echo -e "\n"
    type_text "Finalizing installation..."
    sleep 0.5
    
    clear
    draw_header
    echo -e "${GREEN}===========================================${NC}"
    echo -e "         ${BOLD}INSTALLATION COMPLETE${NC}"
    echo -e "${GREEN}===========================================${NC}"
    echo -e ""
    echo -e "   ${BOLD}Status:${NC}      ${GREEN}Active & Running${NC}"
    echo -e "   ${BOLD}Total Time:${NC}  ${YELLOW}${mins}m ${secs}s${NC}"
    echo -e "   ${BOLD}Logs:${NC}        $LOG_FILE"
    echo -e ""
    echo -e "${CYAN}${BOLD}   NEXT STEPS:${NC}"
    echo -e "   1. Refresh groups:  ${YELLOW}newgrp lxd${NC}"
    echo -e "   2. List containers: ${YELLOW}lxc list${NC}"
    echo -e ""
    echo -e "${DIM}   Thank you for using NotGamerPie Scripts.${NC}"
    echo -e "\n"
}

# --- Main ---
main() {
    hide_cursor
    init_setup
    detect_os
    install_updates
    install_lxd
    configure_user
    init_config
    finish
}

main "$@"
