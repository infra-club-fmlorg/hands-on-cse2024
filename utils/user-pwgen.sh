#!/bin/sh
#
# $FML: user-pwgen.sh,v 1.4 2024/07/13 11:56:32 fukachan Exp $
#

# import local variables
. $(dirname $0)/config.sh

listtmp=./work/list.users

if [ -f $listtmp ];then
    echo "skipping $listtmp (already exists)"
else
    echo "no such file $listtmp, generating ..."

    num=${MAXUSERS:-30}
    for i in $(seq 1 $num)
    do
	randpass=$(dd if=/dev/urandom count=1 bs=128 2>/dev/null | tr -dc 'a-z0-9A-Z' | head -c 16)
	printf "user%02d %s\n" $i $randpass
    done >> $listtmp
fi

rm -v $userlist
ln $listtmp $userlist

exit 0
