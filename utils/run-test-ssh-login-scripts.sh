#!/bin/sh
#
# $FML: run-test-ssh-login-scripts.sh,v 1.2 2024/07/13 12:30:54 fukachan Exp $
#

# Description:
#   utility to test ssh login by password authentication
#   to all users in specifilied $list file

# assert
if [ ! -x /usr/bin/sshpass ];then
    echo "***fatal: no such command <sshpass>, please install it"
    echo "          sudo apt install sshpass"
    exit 1
fi 

list=${1:-work/list.users}

#
# MAIN: show the ssh login scripts for all containers
#
while read user pass
do
	echo "# $user $pass"
	echo ""
	echo "   sshpass -p $pass ssh -o StrictHostKeyChecking=no $user@www.$user.demo.fml.org"
	echo ""

done < $list

exit 0
