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

useradd usuario

usermod -aG sudo usuario

apt install xrdp xorgxrdp dbus-x11 lxde-core lxsession -y

adduser xrdp ssl-cert

usermod -aG ssl-cert xrdp

sudo systemctl start xrdp
sudo systemctl enable xrdp

sudo apt update
sudo apt install chromium -y
