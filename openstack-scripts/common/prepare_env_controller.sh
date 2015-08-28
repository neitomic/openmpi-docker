#!/bin/bash

###########################################
##       Time synchronize service        ##
###########################################
yum -y install ntp
echo 'restrict -4 default kod notrap nomodify' >> /etc/ntp.conf
echo 'restrict -6 default kod notrap nomodify' >> /etc/ntp.conf

systemctl enable ntpd.service
systemctl start ntpd.service

yum install -y yum-plugin-priorities
yum install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

yum install ${OPENSTACK_REPO}

yum -y upgrade

yum -y install openstack-selinux

##########################################
##        Database services             ##
##########################################
yum install -y mariadb mariadb-server MySQL-python

sed -i "/\[mysqld\]/a bind-address = ${CONTROLLER_IP}\ndefault-storage-engine = innodb\ninnodb_file_per_table\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES utf8'\ncharacter-set-server = utf8" /etc/my.cnf

systemctl enable mariadb.service
systemctl start mariadb.service

mysql_secure_installation #need some code to assign root password

yum install rabbitmq-server
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
rabbitmqctl change_password guest ${RABBIT_PASS}
systemctl restart rabbitmq-server.service

mysql -u "root" "-p${MYSQL_PASS}" < ../sql_scripts/create_db_keystone.sql

TOKEN=$(openssl rand -hex 10)

yum install openstack-keystone python-keystoneclient

sed -i "/\[DEFAULT\]/a admin_token = ${TOKEN}" /etc/keystone/keystone.conf
sed -i "/\[database\]/a connection = mysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" /etc/keystone/keystone.conf
sed -i "/\[token\]/a provider = keystone.token.providers.uuid.Provider\ndriver = keystone.token.persistence.backends.sql.Token" /etc/keystone/keystone.conf
sed -i "/\[revoke\]/a driver = keystone.contrib.revoke.backends.sql.Revoke" /etc/keystone/keystone.conf

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /var/log/keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl
su -s /bin/sh -c "keystone-manage db_sync" keystone

systemctl enable openstack-keystone.service
systemctl start openstack-keystone.service

(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
  echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' \
  >> /var/spool/cron/keystone

export OS_SERVICE_TOKEN=${TOKEN}
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0

keystone tenant-create --name admin --description "Admin Tenant"
keystone user-create --name admin --pass ${ADMIN_PASS} --email ${EMAIL_ADDRESS}
keystone role-create --name admin
keystone user-role-add --user admin --tenant admin --role admin

keystone tenant-create --name demo --description "Demo Tenant"
keystone user-create --name demo --tenant demo --pass ${DEMO_PASS} --email ${EMAIL_ADDRESS}

keystone tenant-create --name service --description "Service Tenant"


keystone service-create --name keystone --type identity \
  --description "OpenStack Identity"

keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl http://controller:5000/v2.0 \
  --internalurl http://controller:5000/v2.0 \
  --adminurl http://controller:35357/v2.0 \
  --region regionOne

mysql -u "root" "-p${MYSQL_PASS}" < ../sql_scripts/create_db_glance.sql

source ../admin-openrc.sh

keystone user-create --name glance --pass ${GLANCE_PASS}
keystone user-role-add --user glance --tenant service --role admin
keystone service-create --name glance --type image \
  --description "OpenStack Image Service"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ image / {print $2}') \
  --publicurl http://controller:9292 \
  --internalurl http://controller:9292 \
  --adminurl http://controller:9292 \
  --region regionOne

yum install -y openstack-glance python-glanceclient

sed -i "/\[database\]/a connection = mysql://glance:${GLANCE_DBPASS}@controller/glance" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/a auth_uri = http://controller:5000/v2.0\n\
identity_uri = http://controller:35357\n\
admin_tenant_name = service\n\
admin_user = glance\n\
admin_password = ${GLANCE_PASS}" /etc/glance/glance-api.conf

sed -i "/\[paste_deploy\]/a flavor = keystone" /etc/glance/glance-api.conf
sed -i "#\[glance_store\]#a default_store = file\n\
filesystem_store_datadir = /var/lib/glance/images/" /etc/glance/glance-api.conf

sed -i "/\[DEFAULT\]/a notification_driver = noop" /etc/glance/glance-api.conf

sed -i "/\[database\]/a connection = mysql://glance:${GLANCE_DBPASS}@controller/glance" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/a auth_uri = http://controller:5000/v2.0\n\
identity_uri = http://controller:35357\n\
admin_tenant_name = service\n\
admin_user = glance\n\
admin_password = ${GLANCE_PASS}" /etc/glance/glance-registry.conf

sed -i "/\[paste_deploy\]/a flavor = keystone" /etc/glance/glance-registry.conf

sed -i "/\[DEFAULT\]/a notification_driver = noop" /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance

systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service

