#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

source ${BASE_DIR}/common/openstack.conf

${BASE_DIR}/tools/addHost.sh

${BASE_DIR}/scripts/install-ntp-controller.sh

${BASE_DIR}/scripts/install-openstack-package.sh

${BASE_DIR}/scripts/install-mariadb.sh

${BASE_DIR}/scripts/install-rabbitmq.sh

