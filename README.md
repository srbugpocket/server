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

[+] Info:- Cleaning up temp dir
[+] Info:- Congrats! Crafty is now installed!
[+] Info:- We created a user called 'crafty' for you to run crafty as. (DO NOT RUN CRAFTY WITH ROOT OR SUDO) Switch to crafty user with 'sudo su crafty -'
[+] Info:- Your install is located here: /var/opt/minecraft/crafty
[+] Info:- You can run crafty by running /var/opt/minecraft/crafty/run_crafty.sh
[+] Info:- You can update crafty by running /var/opt/minecraft/crafty/update_crafty.sh
[+] Info:- A service unit file has been saved in /etc/systemd/system/crafty.service
[+] Info:- run this command to enable crafty as a service- 'sudo systemctl enable crafty.service' 
[+] Info:- run this command to start the crafty service- 'sudo systemctl start crafty.service' 

sudo systemctl stop crafty

sudo chown -R crafty:crafty /var/opt/minecraft/crafty

sudo find /var/opt/minecraft/crafty -type d -exec chmod 755 {} \;

sudo find /var/opt/minecraft/crafty -type f -exec chmod 644 {} \;

sudo chmod +x /var/opt/minecraft/crafty/run_crafty.sh

sudo systemctl start crafty
sudo systemctl status crafty
