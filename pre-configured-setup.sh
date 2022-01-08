sudo apt update && sudo apt upgrade
apt install -y openvpn
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
cd  /etc/openvpn/server/
cp /root/client.ovpn /etc/openvpn/server/

systemctl enable openvpn-server@server.service
systemctl status openvpn-server@server.service

cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF

#Generate new password:
#tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '' 
#useradd -p $(openssl passwd -1 LCQzFokjlK) user1
#useradd -p $(openssl passwd -1 XjBuwFeiQs) user2
