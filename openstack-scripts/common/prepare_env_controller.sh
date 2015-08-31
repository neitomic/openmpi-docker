#!/bin/bash

source ../common/openstack.conf

###########################################
##       Time synchronize service        ##
###########################################
yum -y install ntp
echo 'restrict -4 default kod notrap nomodify' >> /etc/ntp.conf
echo 'restrict -6 default kod notrap nomodify' >> /etc/ntp.conf

systemctl enable ntpd.service
systemctl start ntpd.service

yum install -y yum-plugin-priorities
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

yum install -y ${OPENSTACK_REPO}

yum -y upgrade

yum -y install openstack-selinux


#sh install-mariadb.sh

#sh install-rabbitmq.sh

#sh install-keystone-controller.sh

#sh install-glance-controller.sh

#sh install-nova-controller.sh




