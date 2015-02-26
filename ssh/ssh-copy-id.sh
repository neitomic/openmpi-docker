#!/bin/bash
ip_addr=$1

/usr/bin/expect << EOF

spawn ssh-copy-id root@$ip_addr
expect "(yes/no)?"
send "yes\r"
expect "password:"
send "screencat\r"
interact

EOF
