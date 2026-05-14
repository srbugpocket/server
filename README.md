# criador de maquinas virtuais!
bash <(curl -sL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/menu.sh)


apt install xrdp xorgxrdp dbus-x11 lxde-core lxsession -y

adduser xrdp ssl-cert

usermod -aG ssl-cert xrdp

sudo systemctl start xrdp
sudo systemctl enable xrdp

sudo apt update
sudo apt install chromium -y
