#!/bin/sh

sudo apt update && sudo apt upgrade

cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF
apt install -y openvpn 
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
cp /root/client.ovpn /etc/openvpn/client/

#etc.
