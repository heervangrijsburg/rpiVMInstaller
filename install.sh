#!/bin/bash

#install open-vm-tools
echo install open-vm-tools
sudo apt-get install open-vm-tools -y

#install static ip
echo install static ip
sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd
sudo echo "interface eth0 \nstatic ip_address=192.168.1.110/24 \nstatic routers=192.168.1.1 \nstatic domain_name_servers=192.168.1.1" >> /etc/dhcpcd.conf

#install ssh
echo ssh
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

#install fail2ban
sudo apt install fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

#install openvpn
echo openvpn
sudo cd /tmp
sudo wget https://git.io/vpn -O openvpn-install.sh && sudo bash openvpn-install.sh

#install pi-hole
echo pi-hole
sudo cd /tmp
sudo wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh

#install vlan
echo vlan
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
sudo apt install iptables-persistent vlan -y
sudo sh -c "iptables-save > /etc/iptables/rules.v4" 
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo vconfig set_name_type DEV_PLUS_VID_NO_PAD