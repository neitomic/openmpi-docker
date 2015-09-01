#!/usr/bin/expect -f

set PASSWD_CUR [lindex $argv 0]
set PASSWD_NEW [lindex $argv 1]

spawn mysql_secure_installation
expect {Enter current password for root (enter for none):}
send "${PASSWD_CUR}\r"
expect {Set root password? [Y/n] }
send "Y\r"
expect {New password:}
send "${PASSWD_NEW}\r"
expect {Re-enter new password:}
send "${PASSWD_NEW}\r"
expect {Remove anonymous users?}
send "n\r"
expect {Disallow root login remotely?}
send "n\r"
expect {Remove test database and access to it?}
send "Y\r"
expect {Reload privilege tables now?}
send "Y\r"
interact
