#!/bin/bash

yum install -y yum-plugin-priorities
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

yum install -y ${OPENSTACK_REPO}

yum -y upgrade

yum -y install openstack-selinux