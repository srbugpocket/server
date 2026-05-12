# criador de maquinas virtuais!
bash <(curl -sL https://raw.githubusercontent.com/srbugpocket/server/refs/heads/main/menu.sh)


apt install --no-install-recommends lxde-core xorg xrdp -y

sudo systemctl enable xrdp
sudo systemctl start xrdp

apt install firefox-esr
