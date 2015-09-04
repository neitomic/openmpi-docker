#!/bin/bash

KEYSTONE_SQL_FILE=${KEYSTONE_SQL_FILE:-../sql_scripts/create_db_keystone.sql}
sed -i "s/KEYSTONE_DBPASS/${KEYSTONE_DBPASS}/g" ${KEYSTONE_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${KEYSTONE_SQL_FILE}
sed -i "s/${KEYSTONE_DBPASS}/KEYSTONE_DBPASS/g" ${KEYSTONE_SQL_FILE}

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