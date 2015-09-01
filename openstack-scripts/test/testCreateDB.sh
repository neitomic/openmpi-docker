source ../common/openstack.conf

mysql -u root "-p${PASSWORD}" << sed "s/KEYSTONE_DBPASS/${KEYSTONE_DBPASS}/g" ../sql_scripts/create_db_keystone.sql