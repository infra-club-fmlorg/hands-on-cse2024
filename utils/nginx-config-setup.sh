#!/bin/sh
#
# $FML: nginx-config-setup.sh,v 1.4 2024/07/13 11:56:32 fukachan Exp $
#

# import local variables
. $(dirname $0)/config.sh

#
# MAIN
# 
test -d ${nginx_confd_dir}  || mkdir -p ${nginx_confd_dir} 

num=${MAXUSERS:-30}

# default configuration files
cp -pv nginx-ingress/files/conf.d/*conf ${nginx_confd_dir}/ 

# generate nginx configuration files
src=nginx-ingress/files/conf.d/debian-pc.conf
for i in $(seq 1 $num)
do
    user=$(printf "user%02d" $i)
    dst=${nginx_confd_dir}/$user.conf

    sed s/debian-pc/$user/g $src > $dst
done

exit 0
