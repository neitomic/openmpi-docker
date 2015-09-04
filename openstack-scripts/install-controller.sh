#!/bin/bash

source common/openstack.conf

./scripts/install-ntp-controller.sh

./scripts/install-openstack-package.sh

./scripts/install-mariadb.sh

./scripts/install-rabbitmq.sh

