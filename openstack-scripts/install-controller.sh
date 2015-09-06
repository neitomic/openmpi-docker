#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

source ${BASE_DIR}/common/openstack.conf

echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh >> /dev/null
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/install-ntp-controller.sh >> /dev/null
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/install-openstack-package.sh >> /dev/null
echo "Done."
echo "Installing SQL database..."
${BASE_DIR}/scripts/install-mariadb.sh >> /dev/null
echo "Done."
echo "Install Message queue (RabbitMq) ..."
${BASE_DIR}/scripts/install-rabbitmq.sh >> /dev/null
echo "Done."

