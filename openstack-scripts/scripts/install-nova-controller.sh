#!/bin/bash

NOVA_SQL_FILE=${NOVA_SQL_FILE:-../sql_scripts/create_db_nova.sql}
sed -i "s/NOVA_DBPASS/${NOVA_DBPASS}/g" ${NOVA_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${NOVA_SQL_FILE}
sed -i "s/${NOVA_DBPASS}/NOVA_DBPASS/g" ${NOVA_SQL_FILE}

source ../admin-openrc.sh

# keystone user-create --name nova --pass ${NOVA_PASS}
# keystone user-role-add --user nova --tenant service --role admin
# keystone service-create --name nova --type compute \
#   --description "OpenStack Compute"

# keystone endpoint-create \
#   --service-id $(keystone service-list | awk '/ compute / {print $2}') \
#   --publicurl http://controller:8774/v2/%\(tenant_id\)s \
#   --internalurl http://controller:8774/v2/%\(tenant_id\)s \
#   --adminurl http://controller:8774/v2/%\(tenant_id\)s \
#   --region regionOne

openstack user create --password ${NOVA_PASS} nova
openstack role add --project service --user nova admin
openstack service create --name nova \
  --description "OpenStack Compute" compute
openstack endpoint create \
  --publicurl http://controller:8774/v2/%\(tenant_id\)s \
  --internalurl http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl http://controller:8774/v2/%\(tenant_id\)s \
  --region RegionOne \
  compute


yum install -y openstack-nova-api openstack-nova-cert openstack-nova-conductor \
  openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler \
  python-novaclient

sed -i "/\[database\]/a connection = mysql://nova:${NOVA_DBPASS}@controller/nova" /etc/nova/nova.conf

sed -i "/\[DEFAULT\]/a rpc_backend = rabbit\n\
auth_strategy = keystone\n\
my_ip = ${CONTROLLER_IP}\n\
vncserver_listen = ${CONTROLLER_IP}\n\
vncserver_proxyclient_address = ${CONTROLLER_IP}" /etc/nova/nova.conf

sed -i "/^\[oslo_messaging_rabbit\]$/a rabbit_host = controller\n\
rabbit_userid = openstack\n\
rabbit_password = ${RABBIT_PASS}" /etc/nova/nova.conf

sed -i "/\[keystone_authtoken\]/a auth_uri = http://controller:5000\n\
auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = nova\n\
password = ${NOVA_PASS}" /etc/nova/nova.conf

sed -i "/^\[glance\]$/a host = controller" /etc/nova/nova.conf

sed -i "/^\[oslo_concurrency\]$/a lock_path = /var/lib/nova/tmp" /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

systemctl enable openstack-nova-api.service openstack-nova-cert.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service openstack-nova-cert.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service


