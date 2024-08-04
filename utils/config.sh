#
# $FML: config.sh,v 1.4 2024/07/13 11:56:32 fukachan Exp $
#

#
# SSH-GW (SSH PROXY)
#

# we apply this patch to openssh distribution files
conf_patch=ssh-gw/files/sshd.conf.patch

# ssh configurations generated for this system
sshd_dir=./work/etc/ssh

# list of trainees (a set of user and pass)
userlist=$sshd_dir/list.users



#
# NGINX (Web Proxy)
#
# nginx configurations generated for this system
nginx_confd_dir=./work/etc/nginx/conf.d
