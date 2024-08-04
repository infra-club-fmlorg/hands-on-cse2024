#!/bin/sh
#
# $FML: sshd-config-setup.sh,v 1.7 2024/07/13 12:15:58 fukachan Exp $
#

# imported from NetBSD 9.3 /etc/rc.d/sshd and modified to take the argument
sshd_keygen() {
(
	local dir=$1

        keygen="/usr/bin/ssh-keygen"
        umask 022
        while read type bits filename version name;  do
                f="${dir}/$filename"
                if [ -f "$f" ]; then
                        continue
                fi
                case "${bits}" in
                -1)     bitarg=;;
                0)      bitarg="${ssh_keygen_flags}";;
                *)      bitarg="-b ${bits}";;
                esac
                "${keygen}" -t "${type}" ${bitarg} -f "${f}" -N '' -q && \
                    printf "ssh-keygen: " && "${keygen}" -f "${f}" -l
        done << _EOF
dsa     1024    ssh_host_dsa_key        2       DSA
ecdsa   521     ssh_host_ecdsa_key      1       ECDSA
ed25519 -1      ssh_host_ed25519_key    1       ED25519
rsa     0       ssh_host_rsa_key        2       RSA
_EOF
)
}

sshd_config_patch_gen () {
    local num=${MAXUSERS:-30}

    for i in $(seq 1 $num)
    do
	user=$(printf "user%02d" $i)
	sed s/debian-pc/$user/g ${conf_patch}
    done
}


# import local variables
. $(dirname $0)/config.sh

#
# MAIN
# 
test -d ${sshd_dir}  || mkdir -p ${sshd_dir} 

# (1) generate public keys if not exists
sshd_keygen                      ${sshd_dir}

# (2) re-generate /etc/ssh/sshd_config
#     - import ssh-gw/dist/ files
#     - append user configs to ${sshd_dir}/sshd_config file.
cp -vpr ssh-gw/dist/[a-z]*       ${sshd_dir}/
cat ${conf_patch}             >> ${sshd_dir}/sshd_config
sshd_config_patch_gen         >> ${sshd_dir}/sshd_config

# (3) FYI: the "ssh-gw" container volume-mounts ${sshd_dir}/ as /etc/ssh/.
#     see .yml files for more details.

exit 0
