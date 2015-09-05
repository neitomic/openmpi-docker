#!/bin/bash
##########################################
##        Database services             ##
##########################################
PARENT_DIR=$( cd `dirname $0`/.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

yum install -y mariadb mariadb-server MySQL-python expect

sed -i "/\[mysqld\]/a bind-address = ${CONTROLLER_IP}\ndefault-storage-engine = innodb\ninnodb_file_per_table\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES utf8'\ncharacter-set-server = utf8" /etc/my.cnf

systemctl enable mariadb.service
systemctl start mariadb.service

${BASE_DIR}/tools/auto_init_mariadb.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}