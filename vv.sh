#!/bin/bash
var1="192.168.5.1"
var2="192.168.5.10-254"
var3="tmp"
var4="tmp111"
var5="192.168.5.0/24"
which pptpd > /dev/null
if [ "$?" != "0" ]; then
    apt-get install -y pptpd
fi
sed -i "s%localip%#local_old_ip%g" /etc/pptpd.conf
sed -i "s%remoteip%#remote_old_ip%g" /etc/pptpd.conf
echo "localip ${var1}" >> /etc/pptpd.conf
echo "remoteip ${var2}" >> /etc/pptpd.conf

sed -i "s%ms-dns%#old-dns%g" /etc/ppp/options
echo "ms-dns 114.114.114.114" >> /etc/ppp/options
echo "ms-dns 8.8.8.8" >> /etc/ppp/options

# sed -i "s%name pptpd%name ${var1}%g" /etc/ppp/pptpd-options
sed -i "s%name%#na_me%g" /etc/ppp/pptpd-options
echo "name ${var1}" >> /etc/ppp/pptpd-options
echo "logfile /var/log/pptp.log" >> /etc/ppp/pptpd-options

echo "\"${var3}\"    ${var1}  \"${var4}\"  *" >> /etc/ppp/chap-secrets

sed -i "s%net.ipv4.ip_forward=1%#net_old_.ipv4.ip_forward = 1%g" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p


iptables -t nat -A POSTROUTING -s ${var5} -o eth0 -j MASQUERADE
iptables -A forwarding_rule -s ${var5} -j ACCEPT
iptables -I FORWARD -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1356

ls /dev/ppp
if [ "$?" != "0" ]; then
    mknod /dev/ppp c 108 0
fi
/etc/init.d/pptpd restart
exit 0
