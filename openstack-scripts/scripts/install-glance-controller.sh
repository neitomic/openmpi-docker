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

