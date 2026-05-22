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

sudo apt install --no-install-recommends lxde-core lxappearance lxterminal pcmanfm lightdm

adduser xrdp ssl-cert

usermod -aG ssl-cert xrdp

sudo systemctl start xrdp

sudo systemctl enable xrdp

sudo apt update

sudo apt install firefox-esr

sudo apt-get install curl gnupg apt-transport-https

curl -fsSL https://packagecloud.io/pufferpanel/pufferpanel/gpgkey | gpg --dearmor | sudo tee /etc/apt/keyrings/pufferpanel.gpg > /dev/null

echo "X-Repolib-Name: PufferPanel
Types: deb
URIs: https://packagecloud.io/pufferpanel/pufferpanel/any/
Suites: any
Components: main
Signed-By: /etc/apt/keyrings/pufferpanel.gpg" | sudo tee /etc/apt/sources.list.d/pufferpanel.sources > /dev/null

sudo apt update

sudo apt-get install pufferpanel

sudo pufferpanel user add

sudo systemctl enable --now pufferpanel
