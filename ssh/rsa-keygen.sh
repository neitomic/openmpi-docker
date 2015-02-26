#!/bin/bash

/usr/bin/expect << EOF

spawn ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
expect "(y/n)?"
send "y\r"
interact

EOF

