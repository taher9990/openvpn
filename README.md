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

##### Configure OpenVPN: ##### 

Now Edit the server config file 

`
vi /etc/openvpn/server/server.conf
`

`
find / -iname server.conf
`
### Server Configuration File Defaults ###
You can adjust and change some of the default changes, otherwise your VPN clients will have the OpenVPN as their Default Gateway
###### To Disable Default Route, you need add hash (#) infront of below line push....  and other settings e.g. duplicate-cn is for clients to use single config file., and plugin auth-pam iso for users authentication against Ubuntu local users database ######
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

##### To avoid DNS resolutions issues#####
##### On Server Config file Add below options #####

`push "dhcp-option DNS 1.1.1.1"`  &  
`push "block-outside-dns"`

#### TO prevent any routes from server and only specific routes allowed#####
route 10.6.0.0 255.255.255.0
route-nopull

##### On client Config file add below option ##### 
` auth-user-pass `
##### Also disable this option: #####
`#ignore-unknown-option block-outside-dns`
#### but keep below line ####
` block-outside-dns `

```
systemctl enable openvpn-server@server.service
systemctl status openvpn-server@server.service
service openvpn@server restart
#systemctl start openvpn-server@server.service
#systemctl restart openvpn-server@server.service
```
#### Or ####
```
sudo systemctl stop openvpn@server
sudo systemctl start openvpn@server
sudo systemctl restart openvpn@server
sudo systemctl status openvpn@server
```
#### To know which command should be used, you need to know the service daemon location####
```
netstat -paunt | grep openvpn
ps ffaux | grep openvpn
or search by the process Id
ps -aux | grep 1148
You will find the daemon "--daemon"  then look for " --cd" to see where is the path"
```
#### Or to make usre the exact path for server.conf####
```
You can still use find 
find / -iname server.conf
or via the process id explaind above

Default is /etc/openvpn/server/server.conf
Unless mentioned in the ps id  "cd" path section
```
#### Check Network Port 1194 UDP is default ####
```
netstat -tupln
```

![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) 
### Design Notes ### 
In case you have other networks and vms/servers that behind/not directly connected to OpenVPN as default GW, you would need to choose one of the below options to make the VPN clients reach to them and vice versa:
##### 1- Deploye OpenVPN in One Arm Mode: #####
This will require you to ceate NAT Rules on OpenVPN VPN to change VPN Clients source IPs to your local other networks which are behind the OpenVPN VM.

![OpenVPN Connectivity Scenarios-OpenVPN-OneArmMode drawio](https://user-images.githubusercontent.com/3184045/182099875-eccb0ffd-bc2a-48d1-81e5-d28616df5dc2.png)


###### Configure NAT for the Networks that the OpenVPN VM is not a gateway for them: ###### 
```
iptables -t nat -A POSTROUTING -d 10.10.50.0/24 -s 10.8.0.0/24 -j SNAT --to 10.10.50.200
iptables -t nat -A POSTROUTING -d 10.10.100.0/24 -s 10.8.0.0/24 -j SNAT --to 10.10.100.200

sudo apt install -y iptables-persistent netfilter-persistent
sudo iptables-save
iptables-save > /etc/iptables/rules.v4
```

##### 2- Deploy OpenVPN in Two Arm Mode: #####

![OpenVPN Connectivity Scenarios-OpenVPN-TwoArmMode drawio](https://user-images.githubusercontent.com/3184045/182100229-02411079-f588-41f3-92de-df217280dc86.png)



###### Troubleshooting dual profiles ###### 
```
sudo netstat -plnt | grep 119


root@PRD-JUMPHOST:/etc/openvpn# netstat -tulpn | grep 119
udp        0      0 207.180.213.184:1194    0.0.0.0:*                           20181/openvpn
udp        0      0 207.180.213.184:1195    0.0.0.0:*                           796/openvpn



sudo chmod 755 /etc/openvpn/ccd
sudo chmod 644 /etc/openvpn/ccd/dev



sudo chmod 777 /etc/openvpn/ccd
sudo chmod 777 /etc/openvpn/ccd/dev
sudo chmod 777 /etc/openvpn/ccd/ChangeMe


tail -f /var/log/openvpnserver-1194.log | grep -i "ccd\|ifconfig-push\|devuser"
````
