#!/usr/bin/expect -f

set ipadd [lindex $argv 0]

spawn ssh-copy-id root@$ipadd
expect "(yes/no)?"
send "yes\r"
expect "assword:"
send "screencat\r"
expect "assword:"
send "screencat\r"
expect "assword:"
send "screencat\r"
expect "assword:"
send "screencat\r"
interact
