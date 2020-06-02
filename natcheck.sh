#!/bin/bash
cd /home/opc/

#Get up-to-date OCI Public IP addresses list. 
rm -f public_ip_ranges.json
wget https://docs.cloud.oracle.com/iaas/tools/public_ip_ranges.json

#Get current region name from Instance metadata. 
vmmeta=$(curl -L http://169.254.169.254/opc/v1/instance/)
cureg=$(echo $vmmeta | jq '.region')

#Retrieve OCI Object Storage endpoint address list for curent region  . 
REGCIDR=$(cat public_ip_ranges.json | jq '.regions[] | select(.region == '$cureg')')
#REGCIDR=$(cat public_ip_ranges.json | jq '.regions[] | select(.region == "eu-frankfurt-1")')
REGOBJCIDR=$(echo $REGCIDR | jq '.cidrs[] | select(.tags[] == "OBJECT_STORAGE") | .cidr')

#Read current ip from file (/home/opc/curip) 
cur_ip=$(cat curip)

#Check if current ip is still part of Object Storage endpoint CIDR in the selected region.
cidr_clean=$(for cidr in $REGOBJCIDR; do echo $cidr|sed 's/"//g' ; done)
rm -f status
for cidr in $cidr_clean; do ./netmask.sh $cidr | grep $cur_ip; echo $? >> status; done
cat status | grep 0
matchstatus=$(echo $?)
if [ $matchstatus = 0 ]

then
#Current IP address is still in Object Storage CIDR. Do nothing. (Just Log)
        curtime=$(date) 
        echo $curtime "- No change detected" >> /home/opc/log.txt

else
#Current Ip is not anymore in the curent Object Storage CIDR. 
        curtime=$(date)
        echo $curtime "- Object Storage endpoint update detected" >> /home/opc/log.txt

#Resolve object storage name to get fresh IP.
curegnoq=$(echo $vmmeta | jq -r '.region')
newip=$(dig +short objectstorage.$curegnoq.oraclecloud.com. | awk '{line = $0} END {print line}')
echo The new Object Storage IP is : $newip >> /home/opc/log.txt
echo $newip > newip
echo Current $cur_ip >> /home/opc/log.txt
echo New $newip >> /home/opc/log.txt
echo $newip > curip
localip=$(hostname -I | awk '{print $1}')

#Update Firewalld configuration.

#curpfw=$(firewall-cmd --list-forward-ports)
#firewall-cmd --permanent --zone=public --remove-forward-port=$curpfw

firewall-cmd --permanent --zone=public --remove-rich-rule="rule family=ipv4 destination address='$localip' forward-port port=443 protocol=tcp to-port=443 to-addr='$cur_ip'"
#firewall-cmd --permanent --zone=public --add-forward-port=port=443:proto=tcp:toport=443:toaddr=$newip

firewall-cmd --permanent --zone=public --add-rich-rule="rule family=ipv4 destination address='$localip' forward-port port=443 protocol=tcp to-port=443 to-addr='$newip'"
firewall-cmd --reload
systemctl restart firewalld
fi
