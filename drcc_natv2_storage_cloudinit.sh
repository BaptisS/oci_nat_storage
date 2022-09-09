#!/bin/bash
sudo su
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf 
systemctl mask iptables
systemctl stop iptables
firewall-offline-cmd --zone=public --add-port=443/tcp 
firewall-offline-cmd --zone=public --add-masquerade 

vmmeta=$(curl -L http://169.254.169.254/opc/v1/instance/)
curegnoq=$(echo $vmmeta | jq -r '.region')
storip=$(dig +short objectstorage.$curegnoq.oraclecloudXX.com. | awk '{line = $0} END {print line}')
localip=$(hostname -I | awk '{print $1}')
firewall-offline-cmd --zone=public --add-rich-rule="rule family=ipv4 destination address='$localip' forward-port port=443 protocol=tcp to-port=443 to-addr='$storip'"

systemctl restart firewalld

#cd /home/opc/
#@echo $storip > curip
#wget https://raw.githubusercontent.com/BaptisS/oci_nat_storage/master/netmask.sh
#wget https://raw.githubusercontent.com/BaptisS/oci_nat_storage/master/natcheck.sh
#chmod +x netmask.sh
#chmod +x natcheck.sh

#echo "0 */24 * * * /home/opc/natcheck.sh" |crontab -
##echo "* * * * * /home/opc/natcheck.sh" |crontab -
#echo "@reboot /home/opc/natcheck.sh" |crontab -

##firewall-cmd --permanent --zone=testing --add-rich-rule='rule family=ipv4 source address=192.168.1.0/24 masquerade'
##firewall-cmd --permanent --zone=testing --add-rich-rule='rule family=ipv4 source address=192.168.1.0/24 forward-port port=22 protocol=tcp to-port=2222 to-addr=10.0.0.10'
