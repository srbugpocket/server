# criador de maquinas virtuais!

rm -rf ~/.emu
rm -rf ~/.gradle
rm -rf ~/.pub-cache
rm -rf ~/.npm
rm -rf ~/.androidsdkroot
rm -rf ~/.dartServer
rm -rf ~/.config
rm -rf ~/.cache
rm -rf ~/.android

bash <(curl -sL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/menu.sh)

adduser usuario

usermod -aG sudo usuario

sudo apt install cloud-guest-utils -y

sudo growpart /dev/vda 1

sudo resize2fs /dev/vda1

sudo apt install openssh-server -y

apt install xrdp xorgxrdp dbus-x11 -y

sudo apt install --no-install-recommends lxde-core lxterminal pcmanfm

adduser xrdp ssl-cert

usermod -aG ssl-cert xrdp

sudo systemctl start xrdp

sudo systemctl enable xrdp

sudo apt update

sudo apt install chromium

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=Lightingplays

# ---- Base packages (ONE shot, ONE layer) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    docker.io \
    htop \
    btop \
    neovim \
    lsof \
    qemu-system \
    cloud-image-utils \
 && rm -rf /var/lib/apt/lists/*

# ---- Install code-server ----
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ---- Workspace ----
WORKDIR /workspace

EXPOSE 7860

CMD ["code-server", "--bind-addr", "0.0.0.0:7860", "--auth", "none"]
