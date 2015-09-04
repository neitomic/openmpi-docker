#!/bin/bash

###########################################
##       Time synchronize service        ##
###########################################
yum -y install ntp
echo 'restrict -4 default kod notrap nomodify' >> /etc/ntp.conf
echo 'restrict -6 default kod notrap nomodify' >> /etc/ntp.conf

systemctl enable ntpd.service
systemctl start ntpd.service