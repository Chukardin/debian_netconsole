#!/bin/bash

DISTRIB=

install_debian() {

apt-get update > /dev/null

echo "Install arping"
apt-get install -y arping

echo "Download config"
wget https://raw.githubusercontent.com/Chukardin/debian_netconsole/master/netconsole_conf /etc/default/netconsole
echo "Download init script"
wget https://raw.githubusercontent.com/Chukardin/debian_netconsole/master/netconsole /etc/init.d/netconsole

chmod +x /etc/init.d/netconsole

echo "Starting netconsole..."

if [ -e "/sbin/insserv" ]; then
    insserv netconsole
else
    # Probably it's Ubuntu 12.04 without insserv
    if [ -e "/usr/sbin/update-rc.d" ]; then
        update-rc.d netconsole defaults
    fi
fi

/etc/init.d/netconsole start

}

install_debian8() {

apt-get update > /dev/null

echo "Install arping"
apt-get install -y arping

echo "Download config"
wget https://raw.githubusercontent.com/Chukardin/debian_netconsole/master/netconsole_conf /etc/default/netconsole
echo "Download init script"
wget https://raw.githubusercontent.com/Chukardin/debian_netconsole/master/netconsole /etc/init.d/netconsole

chmod +x /etc/init.d/netconsole

echo "Starting netconsole..."

systemctl daemon-reload

insserv netconsole

/etc/init.d/netconsole start

}


install_centos() {

echo "Starting netconsole..."

sed -i "s/#\ SYSLOGADDR=/SYSLOGADDR=148.251.39.245/" /etc/sysconfig/netconsole

chkconfig netconsole on

service netconsole restart

}

if [ -f /etc/os-release ]; then
    DISTRIBFILE=/etc/os-release
else
    DISTRIBFILE=/etc/issue
fi

if grep -Ei 'Debian\ GNU/Linux\ 8' < $DISTRIBFILE > /dev/null; then
    DISTRIB=debian8
elif grep -Ei 'Debian|Ubuntu|Proxmox' < $DISTRIBFILE > /dev/null; then
     DISTRIB=debian
elif grep -Ei 'CentOS|Fedora|Parallels|Citrix XenServer' < $DISTRIBFILE > /dev/null; then
     DISTRIB=centos
fi

case $DISTRIB in
        centos)
        install_centos
        ;;

        debian)
        install_debian
        ;;

        debian8)
        install_debian8
        ;;

esac
