#!/bin/sh
#
# $FML: entrypoint.sh,v 1.6 2024/07/13 12:30:53 fukachan Exp $
#

# (1) prepare the user list which needs password authentication.
#     merged (a) the default users and (b) trainees into /list.users
#      - (a) /list.users
#      - (b) /etc/ssh/lists.users (e.g. user01 - user30)
if [ -f /etc/ssh/list.users ];then
    cat	  /etc/ssh/list.users >> /list.users
    rm -v /etc/ssh/list.users
fi

# (2) create users based on /list.users
while read user pass
do
    printf ">>> create \"%s\" pass={%s}\n" $user $pass >/dev/stderr

    if   [ -x /usr/sbin/useradd ];then
	# debian
        /usr/sbin/useradd -m ${user} < /dev/zero
    elif [ -x /usr/sbin/adduser ];then
	# alpine
        /usr/sbin/adduser    ${user} < /dev/zero
    fi

    # set password
    echo "${user}:${pass}" | /usr/sbin/chpasswd
done < /list.users

# remove the critical data which is used after here.
rm -f /list.users

# (3) prepare miscellaneous setup for ssh server
#     - create directories/files for logging, temporary use
mkdir -p /var/log /var/run/sshd /run/sshd
touch /var/log/btmp
chown root:utmp /var/log/btmp
chmod 660 /var/log/btmp

# (4) run the openssh server in not daemon mode.
#     it means foreground (sshd does not detach the terminal).
exec /usr/sbin/sshd -D

exit
# NOT REACH AFTER HERE

#
# [DEBUG]
#    comment out "exec /usr/sbin/sshd -D" and "exit" above, 
#    edit the following commands e.g. "tail files ...".
while true
do
	echo ""
	tail    /etc/ssh/sshd_config
	tail -5 /etc/passwd
        tail -5 /etc/shadow
	echo ""
	/usr/sbin/sshd -D -d
	echo ""
done
