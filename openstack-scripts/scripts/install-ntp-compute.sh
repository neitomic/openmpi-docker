#!/bin/bash

yum -y install ntp

#Remove all server
sed -i '/server/ s/^/#/' /etc/ntp.conf

#Add controller server

sed -i "/# Please consider joining the pool/a server controller iburst" /etc/ntp.conf

systemctl enable ntpd.service
systemctl start ntpd.service