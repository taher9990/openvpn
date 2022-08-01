### Summary Steps ###
##### Update Ubuntu Packages ##### 

` sudo apt update && sudo apt upgrade `
##### Enable routing: ##### 
```
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF
```


##### Install OpenVPN:##### 
```
apt install -y openvpn 
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
cd  /etc/openvpn/server/
cp /root/client.ovpn /etc/openvpn/server/
```

##### Configure OpenVPN:##### 

Now Edit the file 
`
vi /etc/openvpn/server/server.conf
`
##### Disable below option for the default route  #####
```
#push "redirect-gateway def1 bypass-dhcp" <br>
##Add below static route <br>
push "route 10.10.50.0 255.255.255.0"
#Add below new paramters as well
verb 7
duplicate-cn
##To find the path inside the server use this command dpkg -L openvpn | grep pam
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
```
----------------------

`
/etc/openvpn/server/server.conf
`
##### On client Config file add below option ##### 
` auth-user-pass `
##### Also disable this option: #####
` block-outside-dns `




#### Note ####
In case you have other networks and vms/servers that behind/not directly connected to OpenVPN as default GW, you would need to either to choose one of the below options to make the VPN clients reach to them and vice versa:
1- Create NAT on OpenVPN VPN to change VPN Clients source IPs to your local other networks which are behind the OpenVPN VM.

##### Configure NAT for the Networks that the OpenVPN VM is not a gateway for them: ##### 
```
iptables -t nat -A POSTROUTING -d 10.10.50.0/24 -s 10.8.0.0/24 -j SNAT --to 10.10.50.12
sudo apt install -y iptables-persistent netfilter-persistent
sudo iptables-save
iptables-save > /etc/iptables/rules.v4
```
