yum install openstack-nova-compute sysfsutils

MY_IP=$(sh ../tools/getIPAddress.sh)

sed -i "/\[DEFAULT\]/a rpc_backend = rabbit\n\
rabbit_host = controller\n\
rabbit_password = ${RABBIT_PASS}\n\
auth_strategy = keystone\n\
my_ip = ${MY_IP}\n\
vnc_enabled = True\n\
vncserver_listen = 0.0.0.0\n\
vncserver_proxyclient_address = ${MY_IP}\n\
novncproxy_base_url = http://controller:6080/vnc_auto.html" /etc/nova/nova.conf

sed -i "/\[keystone_authtoken\]/a auth_uri = http://controller:5000/v2.0\n\
identity_uri = http://controller:35357\n\
admin_tenant_name = service\n\
admin_user = nova\n\
admin_password = ${NOVA_PASS}" /etc/nova/nova.conf

sed -i "/\[glance\]/a host = controller" /etc/nova/nova.conf

KVM_SUPPORT=$(sh ../tools/kvmSupport.sh)
if [ ${KVM_SUPPORT} -eq 0 ] 
	sed -i "/\[libvirt\]/a virt_type = qemu" /etc/nova/nova.conf
fi

systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service




