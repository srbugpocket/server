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

apt install xrdp xorgxrdp dbus-x11 lxde-core lxsession -y

adduser xrdp ssl-cert

usermod -aG ssl-cert xrdp

sudo systemctl start xrdp
sudo systemctl enable xrdp

sudo apt update
sudo apt install chromium -y
