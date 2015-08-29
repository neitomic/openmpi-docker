yum install rabbitmq-server
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
rabbitmqctl change_password guest ${RABBIT_PASS}
systemctl restart rabbitmq-server.service