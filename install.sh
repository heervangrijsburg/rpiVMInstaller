#!/bin/bash

read -p "What do you want to be your static ip (also enter subnet)? ex:192.168.1.1/24" staticIP
read -p "What is the ip of your router? ex:192.168.1.1" routerIP
read -p "What is the ip of your domain name server? ex:192.168.1.1" dnsIP
read -p "What is the name of the first interface (for Vlan)?" firstInterface
read -p "What is the name of the second interface (for Vlan)?" secondInterface
read -p "Do you want to install open-vm-tools? answer=yes" installOpenVMTools

#install open-vm-tools
if [ "$installOpenVMTools" = "yes" ]; then
  echo install open-vm-tools
  sudo apt-get install open-vm-tools -y
fi

#install static ip
echo install static ip
sudo systemctl stop dhcpcd
sudo echo "interface eth0" >> /etc/dhcpcd.conf
sudo echo "static ip_address=$staticIP" >> /etc/dhcpcd.conf
sudo echo "static routers=$routerIP" >> /etc/dhcpcd.conf
sudo echo "static domain_name_servers=$dnsIP" >> /etc/dhcpcd.conf
sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd

#install ssh
echo install ssh
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

#install fail2ban
echo install fail2ban
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

#install openvpn
echo install openvpn
sudo cd /tmp
sudo wget https://git.io/vpn -O openvpn-install.sh && sudo bash openvpn-install.sh

#install pi-hole
echo install pi-hole
sudo cd /tmp
sudo wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh

#install vlan
echo install vlan
sudo iptables -t nat -A POSTROUTING -o $firstInterface -j MASQUERADE  
sudo iptables -A FORWARD -i $firstInterface -o $secondInterface -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $secondInterface -o $firstInterface -j ACCEPT
sudo apt install iptables-persistent vlan -y
sudo sh -c "iptables-save > /etc/iptables/rules.v4" 
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo vconfig set_name_type DEV_PLUS_VID_NO_PAD
