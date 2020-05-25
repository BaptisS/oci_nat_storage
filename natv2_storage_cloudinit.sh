#!/bin/bash
sudo su
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf 
systemctl mask iptables
systemctl stop iptables
#firewall-cmd --permanent --zone=public --add-port=443/tcp 
#firewall-cmd --permanent --zone=public --add-masquerade 
#firewall-cmd --permanent --zone=public --add-forward-port=port=443:proto=tcp:toport=443:toaddr=1.2.3.4
#firewall-cmd --reload
firewall-offline-cmd --zone=public --add-port=443/tcp 
firewall-offline-cmd --zone=public --add-masquerade 
firewall-offline-cmd --zone=public --add-forward-port=port=443:proto=tcp:toport=443:toaddr=134.70.43.252
systemctl restart firewalld


cd /home/opc/
echo 1.2.3.4 > curip
wget https://raw.githubusercontent.com/BaptisS/oci_nat_storage/master/netmask.sh
wget https://raw.githubusercontent.com/BaptisS/oci_nat_storage/master/natcheck.sh
chmod +x netmask.sh
chmod +x natcheck.sh

#echo "0 */12 * * * /home/opc/natcheck.sh" |crontab -
echo "* * * * * /home/opc/natcheck.sh" |crontab -

#firewall-cmd --permanent --zone=testing --add-rich-rule='rule family=ipv4 source address=192.168.1.0/24 masquerade'
#firewall-cmd --permanent --zone=testing --add-rich-rule='rule family=ipv4 source address=192.168.1.0/24 forward-port port=22 protocol=tcp to-port=2222 to-addr=10.0.0.10'
